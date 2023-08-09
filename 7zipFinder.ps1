# Uninstall all existing versions
$displayVersionNumber = "23.00.00.0"
$uninstallStrings = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall |
                    Get-ItemProperty |
                    Where-Object { $_.Publisher -eq "Igor Pavlov" -and $_.DisplayVersion -lt $displayVersionNumber} |
                    ForEach-Object { $_.UninstallString }

if ($uninstallStrings) {
Write-Output "Older 7-Zip x86 found installed on the system."
exit 1
} else {
Write-Output "7-Zip is up to date or not found on the system."
exit 0
}