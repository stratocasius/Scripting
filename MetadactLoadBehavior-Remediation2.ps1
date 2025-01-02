# Remediation script for Intune Proactive Remediation
# Define the registry path, value name, and the value to set
$registryPath = "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\ZMetadact Options"
$valueName = "LoadBehavior"
$valueData = 3
# Ensure the registry key exists (should not proceed if it does not, as the detection script handles this case)
if (Test-Path $registryPath) {
    # Create or update LoadBehavior value
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord -Force
    Write-Output "LoadBehavior DWORD value set has been changed to 3"
} else {
    Write-Output "Metadact not installed, no action taken."
}
