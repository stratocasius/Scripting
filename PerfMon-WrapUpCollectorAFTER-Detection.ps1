### PerfMon-WrapUpAFTER Collector Detection - 03/13/2026
### PerfMon-WrapUpCollectorAFTER-Detection.ps1 - Runs collector again for post-nerf perfmon data collection.
# Exit 0 = Compliant  (collector NOT running AND expected final log artifacts exist + non-zero)
# Exit 1 = NonCompliant (collector running OR artifacts missing/zero)
# CMTrace log: C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PerfMon-WrapUpAFTER-Detection.log

$ErrorActionPreference = 'SilentlyContinue'

# -----------------------
# Choose run tag:
#   ""      = BEFORE (original)
#   "AFTER" = AFTER (post-nerf)
# -----------------------
$runTag = "AFTER"   # <-- set to "" for BEFORE, "AFTER" for AFTER

$logDir = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$logPath = Join-Path $logDir "PerfMon-WrapUpAFTER-Detection.log"

$pc = $env:COMPUTERNAME
$mmDDyyyy = Get-Date -Format "MMddyyyy"

# Collector name depends on tag
$collector = if ([string]::IsNullOrWhiteSpace($runTag)) { "JL-Process-HW-Stats4" } else { "JL-Process-HW-Stats4-$runTag" }

# Artifact tag suffix (e.g., "-AFTER" or "")
$tagSuffix = if ([string]::IsNullOrWhiteSpace($runTag)) { "" } else { "-$runTag" }

# Expected final outputs from remediation
$expectedBlgLogName = "$pc-$mmDDyyyy$tagSuffix-BLG.log"
$expectedCsvLogName = "$pc-$mmDDyyyy$tagSuffix-CSV.log"
$expectedBlgLogPath = Join-Path $logDir $expectedBlgLogName
$expectedCsvLogPath = Join-Path $logDir $expectedCsvLogName

function Write-CMTraceLog {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet(1,2,3)][int]$Type = 1,
        [string]$Component = "PerfMon-WrapUp-Detection"
    )
    $time = (Get-Date).ToString("HH:mm:ss.fff") + "+000"
    $date = (Get-Date).ToString("MM-dd-yyyy")
    $line = "<![LOG[$Message]LOG]!><time=""$time"" date=""$date"" component=""$Component"" context="""" type=""$Type"" thread=""$PID"" file=""PerfMon-WrapUp-Detection.ps1"">"
    Add-Content -Path $logPath -Value $line -Encoding UTF8
}

function Get-FileStatus {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (-not (Test-Path $Path)) {
        return [pscustomobject]@{ Exists=$false; Size=0; NonZero=$false }
    }
    try {
        $len = (Get-Item -LiteralPath $Path -ErrorAction Stop).Length
        return [pscustomobject]@{ Exists=$true; Size=$len; NonZero=($len -gt 0) }
    } catch {
        return [pscustomobject]@{ Exists=$true; Size=0; NonZero=$false }
    }
}

Write-CMTraceLog "Start|RunTag=$runTag|Collector=$collector|ExpectBLGLOG=$expectedBlgLogName|ExpectCSVLOG=$expectedCsvLogName"

# ------------------------------------------------------------
# 1) Determine collector status
# ------------------------------------------------------------
$q = logman query $collector 2>$null
$status = "NotFound"
if ($q) {
    $statusLine = ($q | Select-String -SimpleMatch "Status:" | Select-Object -First 1).Line
    if ($statusLine -match "Status:\s*(.+)$") {
        $status = $Matches[1].Trim()
    } else {
        $status = "Unknown"
    }
}
Write-CMTraceLog "Collector|Status=$status"

# If it's Running -> NonCompliant immediately
if ($status -match "Running") {
    Write-CMTraceLog "FAIL|CollectorStillRunning|Status=$status" 3
    Write-Output "NonCompliant|RunTag=$runTag|Collector=$collector|Status=$status|Reason=CollectorRunning"
    exit 1
}

# ------------------------------------------------------------
# 2) Validate expected artifacts exist + are non-zero
# ------------------------------------------------------------
$blg = Get-FileStatus -Path $expectedBlgLogPath
$csv = Get-FileStatus -Path $expectedCsvLogPath

Write-CMTraceLog "Artifacts|BLGLOG|Exists=$($blg.Exists)|Size=$($blg.Size)|Path=$expectedBlgLogPath"
Write-CMTraceLog "Artifacts|CSVLOG|Exists=$($csv.Exists)|Size=$($csv.Size)|Path=$expectedCsvLogPath"

$failReasons = New-Object System.Collections.Generic.List[string]

if (-not $blg.Exists) { $failReasons.Add("Missing=$expectedBlgLogName") | Out-Null }
elseif (-not $blg.NonZero) { $failReasons.Add("ZeroBytes=$expectedBlgLogName") | Out-Null }

if (-not $csv.Exists) { $failReasons.Add("Missing=$expectedCsvLogName") | Out-Null }
elseif (-not $csv.NonZero) { $failReasons.Add("ZeroBytes=$expectedCsvLogName") | Out-Null }

if ($failReasons.Count -gt 0) {
    $reason = ($failReasons -join ";")
    Write-CMTraceLog "FAIL|ArtifactsInvalid|$reason" 3
    Write-Output "NonCompliant|RunTag=$runTag|Collector=$collector|Status=$status|$reason"
    exit 1
}

# ------------------------------------------------------------
# 3) Compliant
# ------------------------------------------------------------
Write-CMTraceLog "PASS|WrapUpComplete|Status=$status|BLGLOG=PresentNonZero|CSVLOG=PresentNonZero" 1
Write-Output "Compliant|RunTag=$runTag|Collector=$collector|Status=$status|BLGLOG=$expectedBlgLogName|CSVLOG=$expectedCsvLogName"
exit 0