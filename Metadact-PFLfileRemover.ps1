$file1ToDelete = "C:\ProgramData\Litera\CorporateCleaningProfiles\High.pfl"
$file2ToDelete = "C:\ProgramData\Litera\CorporateCleaningProfiles\Low.pfl"

$file1Exists = Test-Path $file1ToDelete
$file2Exists = Test-Path $file2ToDelete

if ($file1Exists -and $file2Exists) {
    Remove-Item $file1ToDelete, $file2ToDelete -Force
    Write-Output "Both files 'High.pfl' and 'Low.pfl' were deleted."
} elseif ($file1Exists -or $file2Exists) {
    if ($file1Exists) {
        Remove-Item $file1ToDelete -Force
        Write-Output "The file 'High.pfl' was deleted."
    }
    if ($file2Exists) {
        Remove-Item $file2ToDelete -Force
        Write-Output "The file 'Low.pfl' was deleted."
    }
} else {
    Write-Output "Neither 'High.pfl' nor 'Low.pfl' files were found."
}
