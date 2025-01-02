### Turn On Location Services Detection - 06/27/2024
# Find relevant keys/strings
try {
    # Define registry paths and values
    $regPath1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
    $regValueName1 = "Value"
    $desiredValue1 = "Allow"

    $regPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
    $regValueName2 = "DisableLocation"

    # Check and remediate first registry key
    if (Get-ItemProperty -Path $regPath1 -Name $regValueName1 -ErrorAction SilentlyContinue) {
        $currentValue1 = (Get-ItemProperty -Path $regPath1 -Name $regValueName1).$regValueName1
        if ($currentValue1 -ne $desiredValue1) {
            Write-Output "Remediating registry value needed '$regValueName1' at '$regPath1' from '$currentValue1' to '$desiredValue1'."
            # Set-ItemProperty -Path $regPath1 -Name $regValueName1 -Value $desiredValue1
            Exit 1
        } else {
            Write-Output "Registry value '$regValueName1' at '$regPath1' is already set to '$desiredValue1'."
            Exit 0
        }
    } else {
        Write-Output "Registry key '$regPath1' or value '$regValueName1' does not exist. Creating and setting to '$desiredValue1'."
        # New-ItemProperty -Path $regPath1 -Name $regValueName1 -Value $desiredValue1 -PropertyType String
        Exit 1
    }

    # Check and remediate second registry key
    if (Get-ItemProperty -Path $regPath2 -Name $regValueName2 -ErrorAction SilentlyContinue) {
        Write-Output "Remediating registry value '$regValueName2' at '$regPath2' by removing it."
        Exit 1
        # Remove-ItemProperty -Path $regPath2 -Name $regValueName2
    } else {
        Write-Output "Registry value '$regValueName2' at '$regPath2' does not exist or has already been removed."
        Exit 0
    }

    Write-Output "Remediation complete."

} catch {
    Write-Output "An error occurred: $_"
} finally {
    # End logging
    # Stop-Transcript
}
