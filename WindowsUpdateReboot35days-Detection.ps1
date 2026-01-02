#region Parameters
# Analysis window & correlation sensitivity
$DaysBack            = 35
$CorrelationWindowHr = 8    # consider installs within this many hours before a reboot
$MaxPerCategory      = 200  # cap reads per event category for performance

# Log retention (days)
$LogRetentionDays    = 30
#endregion

$start = (Get-Date).AddDays(-1 * $DaysBack)

#region Logging (no transcript; custom logger only)
# Build timestamped log path
$timestamp   = (Get-Date).ToString('yyyy-MM-dd_HHmm')
$LogDir      = 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs'
$LogBaseName = 'WUfB-Reboots-Detection'
$LogPath     = Join-Path $LogDir "$LogBaseName`_$timestamp.log"

# Ensure directory exists
if (-not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}

# Lightweight logger with retry to avoid occasional file contention
function Write-Log {
    param([Parameter(Mandatory=$true)][string]$Message)

    $attempts = 0
    $maxAttempts = 3
    while ($attempts -lt $maxAttempts) {
        try {
            Add-Content -Path $LogPath -Value ("{0} {1}" -f (Get-Date -Format u), $Message)
            break
        } catch {
            $attempts++
            if ($attempts -ge $maxAttempts) { break }
            Start-Sleep -Milliseconds 150
        }
    }
}

# Cleanup old logs BEFORE writing new one
$oldLogs = @()
try {
    $cutoff  = (Get-Date).AddDays(-$LogRetentionDays)
    $oldLogs = Get-ChildItem -Path $LogDir -Filter "$LogBaseName*_*.log" -File -ErrorAction SilentlyContinue |
               Where-Object { $_.LastWriteTime -lt $cutoff }
    if ($oldLogs) { $oldLogs | Remove-Item -Force -ErrorAction SilentlyContinue }
} catch {
    Write-Log "WARN: Log cleanup failed in $LogDir : $_"
}

# Start-of-run banner (to our custom log only)
Write-Log "=== Detection Script Started ==="
Write-Log "Log file: $LogPath"
if ($cutoff) {
    Write-Log "Retention: $LogRetentionDays day(s); removed $($oldLogs.Count) old log(s) older than $($cutoff.ToString('u'))."
}
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

    # Resolve Title (PS 5.1-safe)
    $title = $null
    if ($data.ContainsKey('updateTitle')) { $title = $data['updateTitle'] }
    elseif ($data.ContainsKey('UpdateTitle')) { $title = $data['UpdateTitle'] }
    elseif ($data.ContainsKey('Title')) { $title = $data['Title'] }
    if (-not $title) { $title = ($Event.Message -split "`r?`n")[0] }

    # Resolve UpdateId
    $updateId = $null
    if ($data.ContainsKey('updateId')) { $updateId = $data['updateId'] }
    elseif ($data.ContainsKey('UpdateId')) { $updateId = $data['UpdateId'] }
    elseif ($data.ContainsKey('UpdateGuid')) { $updateId = $data['UpdateGuid'] }

    # Resolve KB
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

        $primary = if ($instWindow) { $instWindow } else { $recvWindow }

        $kbs    = ($primary | Where-Object KB | Select-Object -Expand KB -Unique)
        $titles = ($primary | Where-Object Title | Select-Object -Expand Title -Unique)

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

function Get-LastRebootInfo {
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        if ($os -and $os.LastBootUpTime) {
            $last = [datetime]$os.LastBootUpTime
            $upt  = (Get-Date) - $last
            return [pscustomobject]@{
                LastReboot   = $last
                Uptime       = $upt
                Source       = 'CIM: Win32_OperatingSystem.LastBootUpTime'
            }
        }
    } catch {}

    try {
        $evt = Get-WinEvent -FilterHashtable @{ LogName='System'; Id=6005 } -ErrorAction SilentlyContinue -MaxEvents 1 |
               Sort-Object TimeCreated -Descending | Select-Object -First 1
        if ($evt) {
            $last = $evt.TimeCreated
            $upt  = (Get-Date) - $last
            return [pscustomobject]@{
                LastReboot = $last
                Uptime     = $upt
                Source     = 'System Log: EventID 6005'
            }
        }
    } catch {}

    return $null
}
#endregion


#region Collect events
Write-Log "Collecting Windows Update and reboot events since $($start.ToString('u'))"

# Windows Update "Received" events (ID 26)
$receivedEvents = Get-WinEvent -FilterHashtable @{
    LogName   = 'Microsoft-Windows-WindowsUpdateClient/Operational'
    ID        = 26
    StartTime = $start
} -ErrorAction SilentlyContinue -MaxEvents $MaxPerCategory
$receivedInfos = if ($receivedEvents) { $receivedEvents | ForEach-Object { Get-UpdateInfoFromWUEvent $_ } } else { @() }
Write-Log ("Received events: {0}" -f $receivedInfos.Count)

# Windows Update "Installed / Success" events (IDs 19, 21, 41)
$installEventIds = 19,21,41
$installedEvents = Get-WinEvent -FilterHashtable @{
    LogName   = 'Microsoft-Windows-WindowsUpdateClient/Operational'
    ID        = $installEventIds
    StartTime = $start
} -ErrorAction SilentlyContinue -MaxEvents $MaxPerCategory
$installedInfos = if ($installedEvents) { $installedEvents | ForEach-Object { Get-UpdateInfoFromWUEvent $_ } } else { @() }
Write-Log ("Installed events: {0}" -f $installedInfos.Count)

# Planned, system-triggered reboot events (1074)
$rebootEvents = Get-WinEvent -FilterHashtable @{
    LogName   = 'System'
    ID        = 1074
    StartTime = $start
} -ErrorAction SilentlyContinue -MaxEvents $MaxPerCategory |
    Where-Object {
        $_.Message -match 'on behalf of (user )?NT AUTHORITY\\SYSTEM' -and
        $_.Message -match 'Operating System: Service pack \(Planned\)'
    }
Write-Log ("Planned SYSTEM reboot events (1074): {0}" -f ($rebootEvents | Measure-Object | Select-Object -ExpandProperty Count))
#endregion


#region Correlate & Output (Log: detailed | Console: one-liner)
# Log last reboot info (any reason)
$lastRebootInfo = Get-LastRebootInfo
if ($lastRebootInfo) {
    $upt = $lastRebootInfo.Uptime
    $uptStr = ("{0}d {1}h {2}m" -f [int]$upt.Days, $upt.Hours, $upt.Minutes)
    Write-Log ("Last Reboot (any reason): {0} | Uptime: {1} | Source: {2}" -f `
        $lastRebootInfo.LastReboot.ToString('u'), $uptStr, $lastRebootInfo.Source)
} else {
    Write-Log "Last Reboot (any reason): N/A"
}

if ($rebootEvents) {
    $joined = Join-NearestWUToReboot -RebootEvents $rebootEvents `
                                     -InstalledInfos $installedInfos `
                                     -ReceivedInfos $receivedInfos `
                                     -WindowHours $CorrelationWindowHr |
              Sort-Object RebootTime -Descending

    # Log a nice table for auditing
    $table = $joined | Select-Object `
        @{n='RebootTime';e={ $_.RebootTime.ToString('u') }},
        KBs, Titles, InstalledAt, ReceivedAt, Confidence |
        Format-Table -AutoSize | Out-String
    Write-Log "Correlation Table:`n$table"

    # Choose the MOST RECENT planned SYSTEM reboot for Intune output
    $latest = $joined | Select-Object -First 1

    $outTime  = if ($latest.RebootTime) { $latest.RebootTime.ToString('u') } else { 'N/A' }
    $outKB    = if ($latest.KBs -and $latest.KBs -ne 'N/A') { $latest.KBs } else { 'N/A' }
    $outTitle = if ($latest.Titles -and $latest.Titles -ne 'N/A') { $latest.Titles } else { 'N/A' }

    # ---------- Intune Detection Output (single line) ----------
    Write-Output "Reboot: $outTime | KB(s): $outKB"
} else {
    Write-Log "No Windows Update-related planned SYSTEM reboots found in the last $DaysBack days."
    # ---------- Intune Detection Output (single line) ----------
    Write-Output "Reboot: N/A | KB(s): N/A | Title: N/A"
}

# End-of-run banner (to our custom log only)
Write-Log "=== Detection Script Completed ==="

exit 0
#endregion
