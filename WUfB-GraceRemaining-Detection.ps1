# =========================
# WUfB KB-Based Grace Window Detector (Event XML parsing + transcript)
# Anchors on EventID 41 (fallback 19/21) for a specific KB.
# Adds +1 day deferral +7 days deadline +1 day grace = +9 total days.
# =========================

#region Settings
$TargetKB            = 'KB5068861'   # Target KB for tracking
$DaysBack            = 35            # Lookback window for events
$DeferralDays        = 1             # Awareness delay
$DeadlineDays        = 7             # Deadline
$GraceDays           = 1             # Grace period
$TotalDaysToGraceEnd = $DeferralDays + $DeadlineDays + $GraceDays  # Typically 9
#endregion

# Transcript setup
$LogDir  = 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs'
$LogPath = Join-Path $LogDir 'WUfB-GraceRemaining.log'

if (-not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}

try {
    Start-Transcript -Path $LogPath -Append -ErrorAction Stop | Out-Null
    Write-Host "=== WUfB Grace Remaining Detection Started: $(Get-Date -Format u) ==="
} catch {
    Write-Warning "Could not start transcript logging to $LogPath : $_"
}

# Core timeframe
$start = (Get-Date).AddDays(-1 * $DaysBack)

# Get device and user
$DeviceName = $env:COMPUTERNAME
try {
    $UserName = (Get-WmiObject -Class Win32_ComputerSystem -ErrorAction Stop).UserName
    if (-not $UserName) { $UserName = 'No active user' }
} catch { $UserName = 'Unknown' }

# Helper: parse KB text
function Get-KBFromText {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
    if ($Text -match '(KB\d{6,7})') { return $matches[1] }
    return $null
}

# Helper: turn an event into a structured object
function Convert-WUEvent {
    param([System.Diagnostics.Eventing.Reader.EventRecord]$Event)
    try {
        $xml = [xml]$Event.ToXml()
        $title = $null
        foreach ($d in $xml.Event.EventData.Data) {
            if ($d.Name -eq 'updateTitle' -or $d.Name -eq 'UpdateTitle' -or $d.Name -eq 'Title') {
                $title = $d.'#text'
                break
            }
        }
        if (-not $title) { $title = ($Event.Message -split "`r?`n")[0] }
        $kb = Get-KBFromText $title
        if (-not $kb) { $kb = Get-KBFromText $Event.Message }

        [pscustomobject]@{
            TimeCreated = $Event.TimeCreated
            Id          = $Event.Id
            Title       = $title
            KB          = $kb
            Record      = $Event
        }
    } catch {
        [pscustomobject]@{
            TimeCreated = $Event.TimeCreated
            Id          = $Event.Id
            Title       = $null
            KB          = Get-KBFromText $Event.Message
            Record      = $Event
        }
    }
}

# Query helper for specific IDs + KB match
function Get-LatestEventForKB {
    param(
        [int[]]$EventIds,
        [string]$KB,
        [datetime]$StartTime
    )
    try {
        $evts = Get-WinEvent -FilterHashtable @{
            LogName      = 'Microsoft-Windows-WindowsUpdateClient/Operational'
            ProviderName = 'Microsoft-Windows-WindowsUpdateClient'
            ID           = $EventIds
            StartTime    = $StartTime
        } -ErrorAction SilentlyContinue -MaxEvents 2000

        if ($evts) {
            $infos = $evts | ForEach-Object { Convert-WUEvent $_ }
            $match = $infos |
                Where-Object { $_.KB -eq $KB -or ($_.Title -and $_.Title -like "*$KB*") } |
                Sort-Object TimeCreated -Descending |
                Select-Object -First 1
            return $match
        }
    } catch {}
    return $null
}

# Try EventID 41 first, fallback to 19/21
$anchorInfo = Get-LatestEventForKB -EventIds 41 -KB $TargetKB -StartTime $start
if (-not $anchorInfo) {
    $anchorInfo = Get-LatestEventForKB -EventIds @(19,21) -KB $TargetKB -StartTime $start
}

# Compute grace window
if ($anchorInfo -and $anchorInfo.TimeCreated) {
    $anchor   = $anchorInfo.TimeCreated
    $graceEnd = $anchor.AddDays($TotalDaysToGraceEnd)
    $now      = Get-Date
    $remaining = $graceEnd - $now
    if ($remaining.TotalSeconds -lt 0) { $remaining = [TimeSpan]::Zero }

    $graceEndsStr = $graceEnd.ToString('u')
    $remainStr    = ('{0}d {1}h {2}m' -f [int]$remaining.Days, $remaining.Hours, $remaining.Minutes)

    Write-Host "Found KB event $($anchorInfo.Id) for $TargetKB at $($anchor.ToString('u'))"
    Write-Host "Calculated Grace End: $graceEndsStr ($remainStr remaining)"
} else {
    $graceEndsStr = 'N/A'
    $remainStr    = 'N/A'
    Write-Host "No qualifying EventID 41/19/21 found for $TargetKB within last $DaysBack days."
}

# Final one-liner output for Intune detection
Write-Output "Device: $DeviceName | User: $UserName | KB: $TargetKB | Grace ends: $graceEndsStr | Grace remaining: $remainStr"

# Close transcript safely
try {
    Write-Host "=== WUfB Grace Remaining Detection Completed: $(Get-Date -Format u) ==="
    Stop-Transcript | Out-Null
} catch {
    Write-Warning "Could not stop transcript: $_"
}

exit 0
