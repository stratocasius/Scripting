### DocXTools Addin - Load Behavior set to 3(all enabled)
$registryPath = "HKLM:\SOFTWARE\Microsoft\Office\Word\Addins\Microsystems.DocXtoolsAddin"
$valueName = "LoadBehavior"
$valueData = "3"
set-ItemProperty -Path $RegistryPath -Name $valueName -Value $valueData -ErrorAction stop
write-output "Remediation complete - DocXTools Addin LoadBehavior DWORD set to 3"