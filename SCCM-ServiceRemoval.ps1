# Stop SCCM related services
Stop-Service -Name "CCMExec" -Force
Stop-Service -Name "SMSAgentHost" -Force

# Uninstall SCCM client
& "$env:windir\ccmsetup\ccmsetup.exe" /uninstall

# Remove SCCM related folders and files
Remove-Item -Path "$env:windir\ccm" -Recurse -Force
Remove-Item -Path "$env:windir\ccmcache" -Recurse -Force
Remove-Item -Path "$env:windir\ccmsetup" -Recurse -Force
Remove-Item -Path "$env:windir\ccmcache" -Recurse -Force
Remove-Item -Path "$env:windir\ccmcache2" -Recurse -Force
Remove-Item -Path "$env:windir\ccmcache3" -Recurse -Force

# Clean up SCCM registry entries
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\CCM" -Recurse -Force
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\SMS" -Recurse -Force

# Remove SCCM WMI namespace and items
(Get-WmiObject -Namespace "root" -Query "SELECT * FROM __Namespace WHERE Name LIKE 'CCM%'").Delete()
(Get-WmiObject -Namespace "root\ccm" -Query "SELECT * FROM __Namespace WHERE Name LIKE 'SMS%'").Delete()
