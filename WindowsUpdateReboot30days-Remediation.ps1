#region Parameters
# Analysis window & correlation sensitivity
$DaysBack            = 35
$CorrelationWindowHr = 8     # consider installs within this many hours before the reboot
$MaxPerCategory      = 200   # cap reads per event category for performance

# Logging
$LogRetentionDays    = 30
$LogDir              = 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs'
$LogBaseName         = 'WUfB-Reboots-Remediation'
#endregion

$start = (Get-Date).AddDays(-1 * $DaysBack)

#region Logging
$timestamp   = (Get-Date).ToString('yyyy-MM-dd_HHmm')
$LogPath     = Join-Path $LogDir "$LogBaseName`_$timestamp.log"

if (-not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}

# Cleanup old logs BEFORE starting transcript
$oldLogs = @()
try {
    $cutoff  = (Get-Date).AddDays(-$LogRetentionDays)
    $oldLogs = Get-ChildItem -Path $LogDir -Filter "$LogBaseName*_*.log" -File -ErrorAction SilentlyContinue |
               Where-Object { $_.LastWriteTime -lt $cutoff }
    if ($oldLogs) { $oldLogs | Remove-Item -Force -ErrorAction SilentlyContinue }
}
catch { Write-Warning "Log cleanup failed in $LogDir : $_" }

try {
    Start-Transcript -Path $LogPath -Force -ErrorAction Stop | Out-Null
    Write-Output "=== WUfB Reboot Remediation Started: $(Get-Date -Format u) ==="
    Write-Output "Log file: $LogPath"
    if ($cutoff) { Write-Output "Retention: $LogRetentionDays day(s); removed $($oldLogs.Count) old log(s) older than $($cutoff.ToString('u'))." }
}
catch { Write-Warning "Could not start transcript logging to $LogPath : $_" }
#endregion

#region Helpers
function Get-EventDataMap {
    param([System.Diagnostics.Eventing.Reader.EventRecord]$Event)
    try {
        $xml = [xml]$Event.ToXml()
        $map = @{}
        foreach ($d in $xml.Event.EventData.Data) {
            $name = if ($d.Name) { $d.Name } else { "Data_$($map.Count)" }
            $map[$name] = $d.'#text'
        }
        return $map
    } catch { return @{} }
}

function Get-KBFromText {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
    if ($Text -match '(KB\d{6,7})') { return $matches[1] }
    return $null
}

function Get-UpdateInfoFromWUEvent {
    param([System.Diagnostics.Eventing.Reader.EventRecord]$Event)

    $data = Get-EventDataMap -Event $Event

    # Title
    $title = $null
    if ($data.ContainsKey('updateTitle')) { $title = $data['updateTitle'] }
    elseif ($data.ContainsKey('UpdateTitle')) { $title = $data['UpdateTitle'] }
    elseif ($data.ContainsKey('Title')) { $title = $data['Title'] }
    if (-not $title) { $title = ($Event.Message -split "`r?`n")[0] }

    # UpdateId
    $updateId = $null
    if ($data.ContainsKey('updateId')) { $updateId = $data['updateId'] }
    elseif ($data.ContainsKey('UpdateId')) { $updateId = $data['UpdateId'] }
    elseif ($data.ContainsKey('UpdateGuid')) { $updateId = $data['UpdateGuid'] }

    # KB
    $kb = Get-KBFromText $title
    if (-not $kb) { $kb = Get-KBFromText $Event.Message }

    [pscustomobject]@{
        TimeCreated = $Event.TimeCreated
        Id          = $Event.Id
        KB          = $kb
        Title       = $title
        UpdateId    = $updateId
        RawMessage  = $Event.Message
        Record      = $Event
    }
}

function Join-NearestWUToReboot {
    param(
        [System.Diagnostics.Eventing.Reader.EventRecord[]]$RebootEvents,
        [object[]]$InstalledInfos,
        [object[]]$ReceivedInfos,
        [int]$WindowHours = 8
    )
    $window = New-TimeSpan -Hours $WindowHours

    foreach ($r in $RebootEvents | Sort-Object TimeCreated) {
        $rt = $r.TimeCreated

        $instWindow = $InstalledInfos |
            Where-Object { $_.TimeCreated -le $rt -and ($rt - $_.TimeCreated) -le $window } |
            Sort-Object TimeCreated -Descending

        $recvWindow = $ReceivedInfos |
            Where-Object { $_.TimeCreated -le $rt -and ($rt - $_.TimeCreated) -le $window } |
            Sort-Object TimeCreated -Descending

        $confidence = if ($instWindow) { 'High' }
                      elseif ($recvWindow) { 'Medium' }
                      else { 'Low' }

        $primary     = if ($instWindow) { $instWindow } else { $recvWindow }
        $kbs         = ($primary | Where-Object KB | Select-Object -Expand KB -Unique)
        $titles      = ($primary | Where-Object Title | Select-Object -Expand Title -Unique)
        $installedAt = if ($instWindow) { ($instWindow | Select-Object -First 1).TimeCreated } else { $null }
        $receivedAt  = if ($recvWindow) { ($recvWindow | Select-Object -First 1).TimeCreated } else { $null }

        $reason = $r.Message -replace '\s+',' ' | ForEach-Object {
            ($_ -split 'Reason:')[1] -replace '^\s+',''
        }

        [pscustomobject]@{
            RebootTime   = $rt
            TriggeredBy  = 'NT AUTHORITY\SYSTEM (Planned OS update)'
            Reason       = if ($reason) { $reason.Trim() } else { 'Operating System: Service pack (Planned)' }
            KBs          = if ($kbs) { ($kbs -join ', ') } else { 'N/A' }
            Titles       = if ($titles) { ($titles -join ' | ') } else { 'N/A' }
            InstalledAt  = if ($installedAt) { $installedAt.ToString('u') } else { $null }
            ReceivedAt   = if ($receivedAt)  { $receivedAt.ToString('u') } else { $null }
            Confidence   = $confidence
        }
    }
}
#endregion

#region Collect events
$receivedEvents = Get-WinEvent -FilterHashtable @{
    LogName   = 'Microsoft-Windows-WindowsUpdateClient/Operational'
    ID        = 26
    StartTime = $start
} -ErrorAction SilentlyContinue -MaxEvents $MaxPerCategory
$receivedInfos = if ($receivedEvents) { $receivedEvents | ForEach-Object { Get-UpdateInfoFromWUEvent $_ } } else { @() }

$installEventIds = 19,21,41
$installedEvents = Get-WinEvent -FilterHashtable @{
    LogName   = 'Microsoft-Windows-WindowsUpdateClient/Operational'
    ID        = $installEventIds
    StartTime = $start
} -ErrorAction SilentlyContinue -MaxEvents $MaxPerCategory
$installedInfos = if ($installedEvents) { $installedEvents | ForEach-Object { Get-UpdateInfoFromWUEvent $_ } } else { @() }

$rebootEvents = Get-WinEvent -FilterHashtable @{
    LogName   = 'System'
    ID        = 1074
    StartTime = $start
} -ErrorAction SilentlyContinue -MaxEvents $MaxPerCategory |
    Where-Object {
        $_.Message -match 'on behalf of (user )?NT AUTHORITY\\SYSTEM' -and
        $_.Message -match 'Operating System: Service pack \(Planned\)'
    }
#endregion

#region Decide remediation outcome
if (-not $rebootEvents) {
    Write-Output "No Windows Update-related planned SYSTEM reboots found in the last $DaysBack days."
    try { Stop-Transcript | Out-Null } catch {}
    exit 0
}

$joined = Join-NearestWUToReboot -RebootEvents $rebootEvents `
                                 -InstalledInfos $installedInfos `
                                 -ReceivedInfos $receivedInfos `
                                 -WindowHours $CorrelationWindowHr |
          Sort-Object RebootTime -Descending

# Log a table for context
$joined | Select-Object `
    @{n='RebootTime';e={ $_.RebootTime.ToString('u') }},
    KBs, Titles, InstalledAt, ReceivedAt, Confidence |
    Format-Table -AutoSize

# Determine if any High-confidence reboots occurred
$high = $joined | Where-Object { $_.Confidence -eq 'High' }

if ($high) {
    # Summarize and exit with non-zero to signal "Remediation" needed/found
    $summary = (
        $high | ForEach-Object {
            $kb = if ($_.KBs -and $_.KBs -ne 'N/A') { $_.KBs } else { 'UnknownKB' }
            "[HighConfidenceReboot: $($_.RebootTime.ToString('u')) | KB(s): $kb]"
        }
    ) -join ' ; '

    Write-Output "High-confidence Windows Update-triggered reboot(s) detected: $summary"
    try {
        Write-Output "=== WUfB Reboot Remediation Completed (non-zero exit): $(Get-Date -Format u) ==="
        Stop-Transcript | Out-Null
    } catch {}
    exit 1
}
else {
    Write-Output "No high-confidence Windows Update-triggered reboots detected."
    try {
        Write-Output "=== WUfB Reboot Remediation Completed (zero exit): $(Get-Date -Format u) ==="
        Stop-Transcript | Out-Null
    } catch {}
    exit 0
}
#endregion