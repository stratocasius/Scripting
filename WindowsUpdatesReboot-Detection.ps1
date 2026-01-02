<#
Intune Detection – Windows Update Installation Events & Mandatory Reboot Deadline
- Reads Windows Update install/restart events
- Reports if restart is pending and how long until mandatory reboot
- Logs full output persistently to IME Logs
Exit 1 = Restart pending (non-compliant)
Exit 0 = No restart pending
#>

# ---------------- Settings ----------------
$LookbackDays = 60
$WUClientLog  = 'Microsoft-Windows-WindowsUpdateClient/Operational'
$EventIds     = 19,20,21,22,31,34,35,43,44

$LogRoot = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\Logs'
$LogPath = Join-Path $LogRoot 'WindowsUpdateRestartDetection.log'

# Ensure log directory exists
if (-not (Test-Path $LogRoot)) { New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null }

# Rotate log if >1 MB
try {
    if (Test-Path $LogPath) {
        if ((Get-Item $LogPath).Length -gt 1MB) {
            $archive = Join-Path $LogRoot ('WindowsUpdateRestartDetection_{0:yyyyMMdd_HHmmss}.log' -f (Get-Date))
            Move-Item -Path $LogPath -Destination $archive -Force
        }
    }
} catch {}

# Unified writer: mirrors output to console and file
function Write-Log {
    param([string]$Message)
    $line = "[{0:yyyy-MM-dd HH:mm:ss}] {1}" -f (Get-Date), $Message
    $line | Out-File -FilePath $LogPath -Append -Encoding UTF8
    Write-Output $line
}

function Try-GetRegValue {
    param([string]$Path,[string]$Name)
    try {
        if (Test-Path $Path) {
            $p = Get-ItemProperty -Path $Path -ErrorAction Stop
            if ($Name -and ($p.PSObject.Properties.Name -contains $Name)) { return $p.$Name }
        }
    } catch {}
    return $null
}

function FileTimeToLocal {
    param([Nullable[UInt64]]$Qw)
    if ($Qw -and $Qw -gt 0) {
        try { return ([DateTime]::FromFileTimeUtc([Int64]$Qw)).ToLocalTime() } catch {}
    }
    return $null
}

Write-Log "==== Detection start {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date)
Write-Log "Scanning for update install events (IDs: $($EventIds -join ', ')) within last $LookbackDays days."

# ---------------- Collect events ----------------
$startTime = (Get-Date).AddDays(-[int]$LookbackDays)
$events = @()
try {
    $events = Get-WinEvent -FilterHashtable @{
        LogName   = $WUClientLog
        Id        = $EventIds
        StartTime = $startTime
    } -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending
} catch {
    Write-Log "Event query failed: $($_.Exception.Message)"
}

if ($events) {
    Write-Log "Found $($events.Count) Windows Update events in lookback window."
} else {
    Write-Log "No Windows Update events found in window."
}

# Summarize latest few events
$events | Select-Object -First 6 | ForEach-Object {
    $msgFirst = (($_.Message -split '\r?\n')[0])
    Write-Log ("  {0:u} | ID {1} | {2}" -f $_.TimeCreated, $_.Id, $msgFirst)
}

# ---------------- Restart status ----------------
$pending = $false
if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') { $pending = $true }
if (Test-Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\RebootRequired') { $pending = $true }
$uxIsPending = Try-GetRegValue -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'IsRestartPending'
if ($uxIsPending -ne $null -and [int]$uxIsPending -ne 0) { $pending = $true }

Write-Log "Restart pending flag: $pending"

# ---------------- Deadline computation ----------------
$deadlineLocal  = $null
$deadlineSource = 'Unknown'
$now            = Get-Date

$engagedDeadline   = Try-GetRegValue -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'EngagedRestartDeadline'
$engagedDeadlineDP = Try-GetRegValue -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'EngagedRestartDeadlineDP'

$deadlineLocal = FileTimeToLocal $engagedDeadline
if (-not $deadlineLocal) { $deadlineLocal = FileTimeToLocal $engagedDeadlineDP }
if ($deadlineLocal) { $deadlineSource = 'UX\Settings EngagedRestartDeadline' }

if (-not $deadlineLocal) {
    $policyPath  = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update'
    $deadlineDays = Try-GetRegValue -Path $policyPath -Name 'AutoRestartDeadlinePeriodInDays'
    $graceDays    = Try-GetRegValue -Path $policyPath -Name 'AutoRestartGracePeriodInDays'
    $totalDays    = $null
    if ($deadlineDays -is [int] -and $deadlineDays -gt 0) { $totalDays = [int]$deadlineDays }
    if ($graceDays -is [int] -and $graceDays -gt 0) { $totalDays = (($totalDays -as [int]) + [int]$graceDays) }

    if ($totalDays -and $events -and $events.Count -gt 0) {
        $baseEvt = $events | Where-Object { $_.Id -in 19,43,44 } | Select-Object -First 1
        if (-not $baseEvt) { $baseEvt = $events | Select-Object -First 1 }
        if ($baseEvt) {
            $deadlineLocal  = $baseEvt.TimeCreated.AddDays($totalDays)
            $deadlineSource = "Policy (deadline=$deadlineDays, grace=$graceDays) + baseEvent ID $($baseEvt.Id)"
        }
    }
}

$remaining = $null
if ($deadlineLocal) { $remaining = ($deadlineLocal - $now) }

# ---------------- Output summary ----------------
Write-Log "=== Restart Status ==="
Write-Log ("  Restart pending: {0}" -f ($(if ($pending) {'Yes'} else {'No'})))
if ($deadlineLocal) {
    Write-Log ("  Mandatory reboot deadline (local): {0:u}  [{1}]" -f $deadlineLocal, $deadlineSource)
    if ($remaining) {
        $sign = $(if ($remaining.TotalSeconds -ge 0) {'in'} else {'OVERDUE by'})
        $abs  = $remaining.Duration()
        $remStr = ("{0} {1}d {2}h {3}m" -f $sign, $abs.Days, $abs.Hours, $abs.Minutes)
        Write-Log ("  Time remaining: {0}" -f $remStr)
    }
} else {
    Write-Log "  Mandatory reboot deadline: Not found (no EngagedRestartDeadline or policy-derived estimate)."
}

Write-Log ""
Write-Log "=== Registry Signals ==="
Write-Log ("  AU\RebootRequired: {0}" -f (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'))
Write-Log ("  Orchestrator\RebootRequired: {0}" -f (Test-Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\RebootRequired'))
Write-Log ("  UX\Settings\IsRestartPending: {0}" -f $uxIsPending)
Write-Log "==== Detection end {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date)

# ---------------- Exit code ----------------
if ($pending) {
    exit 1   # non-compliant → trigger remediation
} else {
    exit 0   # compliant
}
