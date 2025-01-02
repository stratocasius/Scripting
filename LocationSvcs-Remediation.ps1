# Remediation of Location Services for Windows 11.
    # Define registry paths and values
    $regPath1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
    $regValueName1 = "Value"
    $desiredValue1 = "Allow"

    $regPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
    $regValueName2 = "DisableLocation"

#Sets Value string to Allow and removes the DisableLocation string.
Set-ItemProperty -Path $regPath1 -Name $regValueName1 -Value $desiredValue1
# Removes the DisableLocation string
Remove-ItemProperty -Path $regPath2 -Name $regValueName2 -ErrorAction SilentlyContinue
Write-Output "Remediation successful for Value to Allow and removed the DisableLocation string."