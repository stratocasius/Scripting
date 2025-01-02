### Location Services - string Value is set to Allow
$registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\"
$valueName = "Value"
$valueData = "Allow"
set-ItemProperty -Path $RegistryPath -Name $valueName -Value $valueData -ErrorAction stop
write-output "Remediation complete - Location Services enabled."