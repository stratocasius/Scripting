###########################################################################################
### DUO - FailOpen-OfflineAvailable Detection - 03/18/2024
###########################################################################################
# Define the registry key path and value names
$registryPath = "HKLM:\SOFTWARE\Duo Security\DuoCredProv"
$failOpenValueName = "FailOpen"
$offlineAvailableValueName = "OfflineAvailable"

# Check if the registry key exists
if (Test-Path $registryPath) {
    # Get the current values of the FailOpen and OfflineAvailable DWORDs
    $failOpenValue = (Get-ItemProperty -Path $registryPath -Name $failOpenValueName -ErrorAction SilentlyContinue).$failOpenValueName
    $offlineAvailableValue = (Get-ItemProperty -Path $registryPath -Name $offlineAvailableValueName -ErrorAction SilentlyContinue).$offlineAvailableValueName

    # Check if both values are set to 1
    if ($failOpenValue -eq 1 -and $offlineAvailableValue -eq 1) {
        # Return "Compliant" if both values are 1
        Write-Output "Compliant"
        Exit 0
    }
    else {
        # Return "Non-Compliant" if any value is not 1
        Write-Output "Non-Compliant"
        Exit 1
    }
}
else {
    # Return "Non-Compliant" if the registry key doesn't exist
    Write-Output "Non-Compliant"
    Exit 0
}