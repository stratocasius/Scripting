# Define paths
$globalPath = "C:\Program Files\Microsystems\Modules\Microsystems.Data.Enterprise.mdxt"
$userPath = "$env:LOCALAPPDATA\Microsystems\Modules\Microsystems.Data.Enterprise.mdxt"
$targetDate = [datetime]::ParseExact("07/07/2025", "MM/dd/yyyy", $null)

function FileExistsWithCorrectDate($path) {
    if (Test-Path $path) {
        $modDate = (Get-Item $path).LastWriteTime.Date
        return $modDate -eq $targetDate
    }
    return $false
}

# Check both locations
$globalCheck = FileExistsWithCorrectDate -path $globalPath
$userCheck = FileExistsWithCorrectDate -path $userPath

if ($globalCheck -and $userCheck) {
    Write-Output "Both .mdxt files exist and have the correct date modified as 07/07/2025."
    exit 0
} else {
    Write-Output "File missing or date modified does not match. Remediation required."
    exit 1
}
