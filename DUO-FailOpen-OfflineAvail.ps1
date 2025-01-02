# Define the registry key path and value names
$registryPath = "HKLM:\SOFTWARE\Duo Security\DuoCredProv"
$failOpenValueName = "FailOpen"
$offlineAvailableValueName = "OfflineAvailable"

# Log file path
$logFilePath = "C:\Windows\Temp\DUO-FailOpenOfflineAvailable-Configured.log"

# Check if the registry key exists
if (Test-Path $registryPath) {
    # Get the current values of the FailOpen and OfflineAvailable DWORDs
    $failOpenValue = (Get-ItemProperty -Path $registryPath -Name $failOpenValueName -ErrorAction SilentlyContinue).$failOpenValueName
    $offlineAvailableValue = (Get-ItemProperty -Path $registryPath -Name $offlineAvailableValueName -ErrorAction SilentlyContinue).$offlineAvailableValueName

    # Check if the FailOpen value is present and equals 0
    if ($failOpenValue -eq 0) {
        # Set the FailOpen value to 1
        Set-ItemProperty -Path $registryPath -Name $failOpenValueName -Value 1

        # Log the output
        "FailOpen DWORD value was changed to 1." | Out-File -FilePath $logFilePath -Append
    }
    else {
        # Log that the FailOpen value is already configured
        "FailOpen DWORD value is already configured." | Out-File -FilePath $logFilePath -Append
    }

    # Check if the OfflineAvailable value is present and equals 0
    if ($offlineAvailableValue -eq 0) {
        # Set the OfflineAvailable value to 1
        Set-ItemProperty -Path $registryPath -Name $offlineAvailableValueName -Value 1

        # Log the output
        "OfflineAvailable DWORD value was changed to 1." | Out-File -FilePath $logFilePath -Append
    }
    else {
        # Log that the OfflineAvailable value is already configured
        "OfflineAvailable DWORD value is already configured." | Out-File -FilePath $logFilePath -Append
    }
}
else {
    # Log that the registry key doesn't exist
    "Registry key not found: $registryPath" | Out-File -FilePath $logFilePath -Append
}
