# PerfMon-2026-AFTER-Detection.ps1 - 03/13/2026
# Purpose: Ensure AFTER collector has actually produced its BLG in IME Logs root.
# Exit 0 = Compliant  (DataCollector01-AFTER.blg exists and is non-zero)
# Exit 1 = NonCompliant (BLG missing or zero bytes)

$ErrorActionPreference = 'SilentlyContinue'

$logDir   = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$logPath  = Join-Path $logDir "PerfMon-2026-AFTER-Detection.log"

$collector = "JL-Process-HW-Stats4-AFTER"
$blgPath   = Join-Path $logDir "DataCollector01-AFTER.blg"
$csvPath   = Join-Path $logDir "DataCollector01-AFTER.csv"   # optional check/log only

function Write-CMTraceLog {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet(1,2,3)][int]$Type = 1,
        [string]$Component = "PerfMon-2026-AFTER-Detection"
    )
    $time = (Get-Date).ToString("HH:mm:ss.fff") + "+000"
    $date = (Get-Date).ToString("MM-dd-yyyy")
    $line = "<![LOG[$Message]LOG]!><time=""$time"" date=""$date"" component=""$Component"" context="""" type=""$Type"" thread=""$PID"" file=""PerfMon-2026-AFTER-Detection.ps1"">"
    Add-Content -Path $logPath -Value $line -Encoding UTF8
}

function Get-CollectorStatus {
    param([Parameter(Mandatory=$true)][string]$Name)

    $q = logman query $Name 2>$null
    if (-not $q) { return "NotFoundOrNoOutput" }

    $statusLine = ($q | Select-String -SimpleMatch "Status:" | Select-Object -First 1).Line
    if ($statusLine -match "Status:\s*(.+)$") { return $Matches[1].Trim() }

    return "Unknown"
}

function Get-FileLen {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (-not (Test-Path $Path)) { return -1 }
    try { return (Get-Item -LiteralPath $Path -ErrorAction Stop).Length } catch { return 0 }
}

Write-CMTraceLog "Start|Collector=$collector|BLG=$blgPath|CSV=$csvPath"

# Status (for troubleshooting)
$status = Get-CollectorStatus -Name $collector
Write-CMTraceLog "Collector|Status=$status"

# File checks
$blgLen = Get-FileLen -Path $blgPath
$csvLen = Get-FileLen -Path $csvPath

if ($blgLen -lt 0) {
    # BLG missing -> NonCompliant (this is what you asked for)
    Write-CMTraceLog "FAIL|BLGMissing|Status=$status|Path=$blgPath" 3
    Write-Output "NonCompliant|AFTER|Collector=$collector|Status=$status|BLG=Missing"
    exit 1
}

if ($blgLen -eq 0) {
    # BLG exists but zero -> treat as NonCompliant to avoid edge cases
    Write-CMTraceLog "FAIL|BLGZeroBytes|Status=$status|Path=$blgPath" 3
    Write-Output "NonCompliant|AFTER|Collector=$collector|Status=$status|BLG=ZeroBytes"
    exit 1
}

# Optional: just log CSV presence (don’t fail on it — export is best-effort in your start script)
if ($csvLen -lt 0) {
    Write-CMTraceLog "WARN|CSVMissing|Path=$csvPath|Note=StartScriptExportIsBestEffort" 2
} elseif ($csvLen -eq 0) {
    Write-CMTraceLog "WARN|CSVZeroBytes|Path=$csvPath|Note=StartScriptExportIsBestEffort" 2
} else {
    Write-CMTraceLog "Info|CSVPresent|Size=$csvLen|Path=$csvPath" 1
}

Write-CMTraceLog "PASS|BLGPresent|Size=$blgLen|Status=$status" 1
Write-Output "Compliant|AFTER|Collector=$collector|Status=$status|BLG=Present|Size=$blgLen"
exit 0