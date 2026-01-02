<#
Intune Detection – Minimal console output
- Console: ONLY prints if a restart is pending and how much time remains (or 'N/A')
- Log file: C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\WindowsUpdateRestartDetection.log
Exit 1 = Restart pending
Exit 0 = No restart pending
#>

# -------- Settings --------
$LookbackDays = 30
$WUClientLog  = 'Microsoft-Windows-WindowsUpdateClient/Operational'
$EventIds     = 19,20,21,22,31,34,35,43,44

$LogRoot = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\Logs'
$LogPath = Join-Path $LogRoot 'WindowsUpdateRestartDetection.log'

# -------- Logging (file-only) --------
if (-not (Test-Path $LogRoot)) { New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null }
try {
    if (Test-Path $LogPath) {
        if ((Get-Item $LogPath).Length -gt 1MB) {
            $archive = Join-Path $LogRoot ('WindowsUpdateRestartDetection_{0:yyyyMMdd_HHmmss}.log' -f (Get-Date))
            Move-Item -Path $LogPath -Destination $archive -Force
        }
    }
} catch {}

function Write-Log {
    param([string]$Message)
    "[{0:yyyy-MM-dd HH:mm:ss}] {1}" -f (Get-Date), $Message | Out-File -FilePath $LogPath -Append -Encoding UTF8
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

# -------- Start --------
Write-Log "==== Detection start ===="

# Determine restart pending
$pending = $false
if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') { $pending = $true }
if (Test-Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\RebootRequired') { $pending = $true }
$uxIsPending = Try-GetRegValue -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'IsRestartPending'
if ($uxIsPending -ne $null -and [int]$uxIsPending -ne 0) { $pending = $true }
Write-Log ("Restart pending = {0}" -f $pending)

# Compute deadline (prefer EngagedRestartDeadline)
$deadlineLocal  = $null
$deadlineSource = 'Unknown'
$engagedDeadline   = Try-GetRegValue -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'EngagedRestartDeadline'
$engagedDeadlineDP = Try-GetRegValue -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'EngagedRestartDeadlineDP'
$deadlineLocal = FileTimeToLocal $engagedDeadline
if (-not $deadlineLocal) { $deadlineLocal = FileTimeToLocal $engagedDeadlineDP }
if ($deadlineLocal) { $deadlineSource = 'UX\Settings EngagedRestartDeadline' }

# Fallback: derive from policy + latest install event
if (-not $deadlineLocal) {
    $policyPath   = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update'
    $deadlineDays = Try-GetRegValue -Path $policyPath -Name 'AutoRestartDeadlinePeriodInDays'
    $graceDays    = Try-GetRegValue -Path $policyPath -Name 'AutoRestartGracePeriodInDays'

    $totalDays = $null
    if ($deadlineDays -is [int] -and $deadlineDays -gt 0) { $totalDays = [int]$deadlineDays }
    if ($graceDays   -is [int] -and $graceDays   -gt 0) { $totalDays = (($totalDays -as [int]) + [int]$graceDays) }

    if ($totalDays) {
        $startTime = (Get-Date).AddDays(-[int]$LookbackDays)
        try {
            $events = Get-WinEvent -FilterHashtable @{
                LogName   = $WUClientLog
                Id        = $EventIds
                StartTime = $startTime
            } -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending
        } catch { $events = @() }

        if ($events -and $events.Count -gt 0) {
            $baseEvt = $events | Where-Object { $_.Id -in 19,43,44 } | Select-Object -First 1
            if (-not $baseEvt) { $baseEvt = $events | Select-Object -First 1 }
            if ($baseEvt) {
                $deadlineLocal  = $baseEvt.TimeCreated.AddDays($totalDays)
                $deadlineSource = "Policy-derived (deadline=$deadlineDays, grace=$graceDays; baseEvent ID $($baseEvt.Id))"
            }
        }
    }
}

$remaining = $null
if ($deadlineLocal) { $remaining = ($deadlineLocal - (Get-Date)) }

# Log details to file only
Write-Log ("Deadline source: {0}" -f $deadlineSource)
Write-Log ("Deadline (local): {0}" -f ($(if ($deadlineLocal) { $deadlineLocal.ToString('u') } else { 'N/A' })))
if ($remaining) {
    $abs = $remaining.Duration()
    Write-Log ("Time remaining (abs): {0}d {1}h {2}m" -f $abs.Days, $abs.Hours, $abs.Minutes)
} else {
    Write-Log "Time remaining: N/A"
}
Write-Log "==== Detection end ===="

# -------- Minimal console output (ONLY) --------
if ($pending) {
    # Build friendly remaining string for console
    $remStr = 'N/A'
    if ($remaining) {
        $sign = $(if ($remaining.TotalSeconds -ge 0) {'in'} else {'OVERDUE by'})
        $abs  = $remaining.Duration()
        $remStr = ("{0} {1}d {2}h {3}m" -f $sign, $abs.Days, $abs.Hours, $abs.Minutes)
    }
    Write-Output ("RestartPending=True; TimeRemaining={0}" -f $remStr)
    exit 1
} else {
    Write-Output "RestartPending=False"
    exit 0
}
