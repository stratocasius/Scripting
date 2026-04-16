### PerfMon-WrapUp Collector-Detection.ps1 - 03/10/2026
### Looks for file(s) from PerfMon's 6hr run that are renamed for easy retrieval.
# Exit 0 = Compliant (renamed BLG+CSV exist)
# Exit 1 = Non-Compliant (either file missing)

$ErrorActionPreference = 'SilentlyContinue'

$basePath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$mmddyyyy = Get-Date -Format "MMddyyyy"

$pc       = $env:COMPUTERNAME

$blgExpected = Join-Path $basePath "$pc-$MMddyyyy-BLG.log"
$csvExpected = Join-Path $basePath "$pc-$MMddyyyy-CSV.log"

$blgExists = Test-Path $blgExpected
$csvExists = Test-Path $csvExpected

if ($blgExists -and $csvExists) {

    Write-Output "Compliant|BLG=Present|CSV=Present|BLGName=$($pc)-$mmddyyyyBLG.log|CSVName=$($pc)-$mmddyyyyCSV.log"

    exit 0

} else {

    $missing = @()

    if (-not $blgExists) { $missing += "BLG" }

    if (-not $csvExists) { $missing += "CSV" }

    Write-Output "NonCompliant|Missing=$($missing -join ',')|BLG=$blgExpected|CSV=$csvExpected"

    exit 1

}
 