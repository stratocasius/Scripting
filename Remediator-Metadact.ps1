############## Metadact Addin Remediation
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\ZMetadact Options"  # Replace with the actual Registry path
$RegistryName = "LoadBehavior"  # Replace with the actual value name
$DesiredValue = 2

New-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $DesiredValue -PropertyType DWORD -Force

Write-Host "The Registry DWORD value has been set to $DesiredValue."