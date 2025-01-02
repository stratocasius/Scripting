# Remediation script for Intune Proactive Remediation
# Define the registry path, value name, and the value to set
$registryPath = "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\ZMetadact Options"
$valueName = "LoadBehavior"
$valueData = 3
    # Create or update LoadBehavior value
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord
    Write-Output "Changed LoadBehavior DWORD to value of 3"
else {
    Write-Output "Metadact not installed, no action taken."
}
