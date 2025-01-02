#### Windows Hello PIN Finder()
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$propertyName = "AllowDomainPINLogon"

# Get the current value of the registry setting
$currentValue = (Get-ItemProperty -Path $registryPath -Name $propertyName).$propertyName
Write-Output "Registry value '$currentvalue'"
