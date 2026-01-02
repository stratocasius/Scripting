$targetPath = "C:\ProgramData\Litera\CorporateCleaningProfiles"
$filesToDelete = @("Low.pfl", "High.pfl")

foreach ($file in $filesToDelete) {
    $fullPath = Join-Path -Path $targetPath -ChildPath $file
    if (Test-Path $fullPath) {
        ### Remove-Item $fullPath -Force
        Write-Output "PFL File found at $fullPath"
        Exit 1
    } else {
        Write-Output "Not found at $fullPath"
        Exit 0
    }
}