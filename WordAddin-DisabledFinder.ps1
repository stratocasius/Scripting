###################################################################################
# Specify the target registry path
$registryPath = "HKLM:SOFTWARE\Microsoft\Office\Word\Addins\"

# Specify the target value (DWORD) to search for
$targetValue = 3

# Get all registry subkeys under the specified path
$subkeys = Get-ChildItem -Path $registryPath

# Initialize an array to store the registry keys with the target value
$keysWithTargetValue = @()

# Iterate through subkeys and check for the target value
foreach ($subkey in $subkeys) {
    $value = Get-ItemProperty -Path $subkey.PSPath
    $dwordValue = $value.PSObject.Properties | Where-Object { $_.Value -eq $targetValue }

    if ($dwordValue -ne $null) {
        $keysWithTargetValue += $subkey.PSPath
    }
}
# Report the registry keys with the target value
if ($keysWithTargetValue.Count -gt 0) {
    Write-Host "Disabled Word Add-ins:"
    foreach ($key in $keysWithTargetValue) {
        Write-Host "$subkeys"
    }
} else {
    Write-Host "No Disabled Word Add-ins were found."
}
