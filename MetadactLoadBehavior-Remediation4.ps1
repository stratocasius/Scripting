### Metadact Outlook Addin - Load Behavior set to 3(all enabled)
$registryPath = "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\ZMetadact Options\"
$valueName = "LoadBehavior"
$valueData = "3"
set-ItemProperty -Path $RegistryPath -Name $valueName -Value $valueData -ErrorAction stop
write-output "Remediation complete - Addin LoadBehavior dword set to 3"
