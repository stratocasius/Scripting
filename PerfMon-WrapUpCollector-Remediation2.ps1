# PerfMon-WrapUp Collector-Remediation.ps1 - 03/09/2026
# Stops collector (if running), renames BLG, exports CSV, logs to CMTrace-style file.

$ErrorActionPreference = 'SilentlyContinue'

$logDir = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$logPath = Join-Path $logDir "PerfMon-WrapUp.log"

$collector = "JL-Process-HW-Stats4"
$basePath  = $logDir

$srcBlg = Join-Path $basePath "DataCollector01.blg"
$srcCsv = Join-Path $basePath "DataCollector01.csv"

$ddMMyyyy = Get-Date -Format "ddMMyyyy"
$finalBlgName = "$($env:COMPUTERNAME)-$ddMMyyyyBLG.log"
$finalCsvName = "$($env:COMPUTERNAME)-$ddMMyyyyCSV.log"
$finalBlg = Join-Path $basePath $finalBlgName
$finalCsv = Join-Path $basePath $finalCsvName

function Write-CMTraceLog {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet(1,2,3)][int]$Type = 1,
        [string]$Component = "PerfMon-WrapUp"
    )
    $time = (Get-Date).ToString("HH:mm:ss.fff") + "+000"
    $date = (Get-Date).ToString("MM-dd-yyyy")
    $line = "<![LOG[$Message]LOG]!><time=""$time"" date=""$date"" component=""$Component"" context="""" type=""$Type"" thread=""$PID"" file=""PerfMon-WrapUp-Remediation.ps1"">"
    Add-Content -Path $logPath -Value $line -Encoding UTF8
}

Write-CMTraceLog "Start|Collector=$collector|Computer=$env:COMPUTERNAME"

# Query status
$q = logman query $collector 2>$null
$statusLine = ($q | Select-String -SimpleMatch "Status:" | Select-Object -First 1).Line
$status = if ($statusLine -match "Status:\s*(.+)$") { $Matches[1].Trim() } else { "Unknown" }
Write-CMTraceLog "PreCheck|Status=$status"

# Stop if running
if ($status -match "Running") {
    Write-CMTraceLog "Action|Stopping collector $collector" 2
    try {
        logman stop $collector -ets 2>$null | Out-Null
        Start-Sleep -Seconds 3
    } catch {
        Write-CMTraceLog "ERROR|Failed to stop collector: $($_.Exception.Message)" 3
    }
} else {
    Write-CMTraceLog "Info|Collector not running; continuing with file operations" 1
}

# Wait for BLG to exist and/or unlock
$waitSeconds = 60
$end = (Get-Date).AddSeconds($waitSeconds)
while ((Get-Date) -lt $end -and -not (Test-Path $srcBlg)) {
    Start-Sleep -Seconds 3
}

if (-not (Test-Path $srcBlg)) {
    Write-CMTraceLog "WARN|BLG not found at expected path: $srcBlg" 2
    Write-Output "Done|BLGNotFound|$srcBlg"
    exit 0
}

# Rename/move BLG to COMPUTERNAME-DDMMYYYY.blg
try {
    if (Test-Path $finalBlg) { Remove-Item $finalBlg -Force -ErrorAction SilentlyContinue }
    Rename-Item -Path $srcBlg -NewName $finalBlgName -Force -ErrorAction Stop
    Write-CMTraceLog "OK|Renamed BLG|$finalBlg"
} catch {
    # If rename fails (lock), fall back to copy then leave original
    Write-CMTraceLog "WARN|Rename failed (likely locked). Attempting CopyItem. Error=$($_.Exception.Message)" 2
    try {
        Copy-Item -Path $srcBlg -Destination $finalBlg -Force -ErrorAction Stop
        Write-CMTraceLog "OK|Copied BLG|$finalBlg"
    } catch {
        Write-CMTraceLog "ERROR|Copy failed: $($_.Exception.Message)" 3
    }
}

# Export CSV from the final BLG (preferred) else from source BLG
$blgForExport = if (Test-Path $finalBlg) { $finalBlg } else { $srcBlg }

try {
    if (Test-Path $finalCsv) { Remove-Item $finalCsv -Force -ErrorAction SilentlyContinue }
    $relog = "relog `"$blgForExport`" -f CSV -o `"$finalCsv`""
    Invoke-Expression $relog | Out-Null
    if (Test-Path $finalCsv) {
        Write-CMTraceLog "OK|Exported CSV|$finalCsv"
    } else {
        Write-CMTraceLog "WARN|relog ran but CSV not found at $finalCsv" 2
    }
} catch {
    Write-CMTraceLog "WARN|CSV export failed: $($_.Exception.Message)" 2
}

# Post status
$q2 = logman query $collector 2>$null
$statusLine2 = ($q2 | Select-String -SimpleMatch "Status:" | Select-Object -First 1).Line
$status2 = if ($statusLine2 -match "Status:\s*(.+)$") { $Matches[1].Trim() } else { "Unknown" }
Write-CMTraceLog "End|Status=$status2|FinalBLG=$finalBlgName|FinalCSV=$finalCsvName"

Write-Output "Done|Status=$status2|BLG=$finalBlgName|CSV=$finalCsvName"
#exit 0
# ============================================================
# Optional: Best-effort copy BLG/CSV to NAS (non-fatal)
# ============================================================

$nasRoot = "\\vm-nasuni-01\shares"
$computer = $env:COMPUTERNAME
$stamp = Get-Date -Format "ddMMyyyy"

# Source files (adjust if you renamed them earlier)
$srcBlg = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\$computer-$stamp.blg"
$srcCsv = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\$computer-$stamp.csv"

# Destination filenames (keeps them unique per device/day)
$dstBlg = Join-Path $nasRoot "$computer-$stamp.blg"
$dstCsv = Join-Path $nasRoot "$computer-$stamp.csv"

try {
    if (-not (Test-Path $nasRoot)) {
        Write-Output "NASCopy: Share not reachable: $nasRoot (skipping)"
    } else {
        if (Test-Path $srcBlg) {
            Copy-Item -Path $srcBlg -Destination $dstBlg -Force -ErrorAction Stop
            Write-Output "NASCopy: BLG copied to $dstBlg"
        } else {
            Write-Output "NASCopy: BLG missing at $srcBlg (skipping)"
        }

        if (Test-Path $srcCsv) {
            Copy-Item -Path $srcCsv -Destination $dstCsv -Force -ErrorAction Stop
            Write-Output "NASCopy: CSV copied to $dstCsv"
        } else {
            Write-Output "NASCopy: CSV missing at $srcCsv (skipping)"
        }
    }
}
catch {
    Write-Output "NASCopy: Copy attempt failed (non-fatal): $($_.Exception.Message)"
}