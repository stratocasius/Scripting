# PerfMon-WrapUp Collector-Remediation.ps1 - 03/10/2026
# Stops collector (if running), renames BLG, exports CSV, then renames both to *.log with -BLG / -CSV suffixes.

$ErrorActionPreference = 'SilentlyContinue'

$logDir  = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$logPath = Join-Path $logDir "PerfMon-WrapUp.log"

$collector = "JL-Process-HW-Stats4"
$basePath  = $logDir

$srcBlg = Join-Path $basePath "DataCollector01.blg"
$srcCsv = Join-Path $basePath "DataCollector01.csv"

$ddMMyyyy = Get-Date -Format "MMddyyyy"
$pc = $env:COMPUTERNAME

# First-pass names (as you already do)
$finalBlgName = "$pc-$ddMMyyyy.BLG"
$finalCsvName = "$pc-$ddMMyyyy.CSV"
$finalBlg     = Join-Path $basePath $finalBlgName
$finalCsv     = Join-Path $basePath $finalCsvName

# Second-pass names (requested)
$finalBlgLogName = "$pc-$ddMMyyyy-BLG.log"
$finalCsvLogName = "$pc-$ddMMyyyy-CSV.log"
$finalBlgLog     = Join-Path $basePath $finalBlgLogName
$finalCsvLog     = Join-Path $basePath $finalCsvLogName

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

Write-CMTraceLog "Start|Collector=$collector|Computer=$pc"

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

# Wait for BLG to exist
$waitSeconds = 60
$end = (Get-Date).AddSeconds($waitSeconds)
while ((Get-Date) -lt $end -and -not (Test-Path $srcBlg)) { Start-Sleep -Seconds 3 }

if (-not (Test-Path $srcBlg)) {
    Write-CMTraceLog "WARN|BLG not found at expected path: $srcBlg" 2
    Write-Output "Done|BLGNotFound|$srcBlg"
    exit 0
}

# Rename/move BLG to COMPUTERNAME-DDMMYYYY.BLG
try {
    if (Test-Path $finalBlg) { Remove-Item $finalBlg -Force -ErrorAction SilentlyContinue }
    Rename-Item -Path $srcBlg -NewName $finalBlgName -Force -ErrorAction Stop
    Write-CMTraceLog "OK|Renamed BLG|$finalBlg"
} catch {
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

# ============================================================
# Final rename pass: BLG/CSV -> *-BLG.log and *-CSV.log
# ============================================================

function Finalize-ToLogName {
    param(
        [Parameter(Mandatory=$true)][string]$SourcePath,
        [Parameter(Mandatory=$true)][string]$DestPath,
        [Parameter(Mandatory=$true)][string]$Label
    )
    try {
        if (Test-Path $SourcePath) {
            if (Test-Path $DestPath) { Remove-Item $DestPath -Force -ErrorAction SilentlyContinue }
            Rename-Item -Path $SourcePath -NewName (Split-Path $DestPath -Leaf) -Force -ErrorAction Stop
            Write-CMTraceLog "OK|FinalRename|$Label|$DestPath"
        } else {
            Write-CMTraceLog "WARN|FinalRename|$Label|SourceMissing=$SourcePath" 2
        }
    } catch {
        Write-CMTraceLog "WARN|FinalRenameFailed|$Label|$($_.Exception.Message)" 2
    }
}

# Prefer the already-renamed “final” names if present; otherwise fall back to the originals.
$blgToFinalize = if (Test-Path $finalBlg) { $finalBlg } elseif (Test-Path $srcBlg) { $srcBlg } else { $null }
$csvToFinalize = if (Test-Path $finalCsv) { $finalCsv } elseif (Test-Path $srcCsv) { $srcCsv } else { $null }

if ($blgToFinalize) { Finalize-ToLogName -SourcePath $blgToFinalize -DestPath $finalBlgLog -Label "BLG" }
if ($csvToFinalize) { Finalize-ToLogName -SourcePath $csvToFinalize -DestPath $finalCsvLog -Label "CSV" }

# Post status
$q2 = logman query $collector 2>$null
$statusLine2 = ($q2 | Select-String -SimpleMatch "Status:" | Select-Object -First 1).Line
$status2 = if ($statusLine2 -match "Status:\s*(.+)$") { $Matches[1].Trim() } else { "Unknown" }

Write-CMTraceLog "End|Status=$status2|FinalBLGLOG=$finalBlgLogName|FinalCSVLOG=$finalCsvLogName"
Write-Output "Done|Status=$status2|BLGLOG=$finalBlgLogName|CSVLOG=$finalCsvLogName"
exit 0