# Check for Windows Updates
$updateResults = Get-WindowsUpdate -MicrosoftUpdate -IgnoreUserPreferences

# Filter out the results for Safeguard holds
$safeguardHolds = $updateResults | Where-Object {
    $_.Title -like "*Safeguard*" -or $_.Description -like "*Safeguard*"
}

# Check if any Safeguard holds were found
if ($safeguardHolds) {
    Write-Output "This PC is under a Safeguard hold for updating to Windows 11."
    $safeguardHolds | Format-Table -Property Title, Description, Severity
    Exit 1
} else {
    Write-Output "This PC is not under a Safeguard hold for updating to Windows 11."
    Exit 0
}