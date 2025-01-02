### ndMail Outlook Addin - Load Behavior set to 3(all enabled)
$registryPath = "HKCU:\Software\Microsoft\Office\Outlook\Addins\LexisNexis.InterAction.Outlook2016.AddIn\"
$valueName = "LoadBehavior"
$valueData = "3"
set-ItemProperty -Path $RegistryPath -Name $valueName -Value $valueData -ErrorAction stop
write-output "Remediation complete - Addin LoadBehavior dword set to 3"
