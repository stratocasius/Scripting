######################################################################################################################
### JL Word Startup Template Removal. 04/04/2024 - Uninstaller for JL Word Startup Template.
######################################################################################################################
### Log path
$logFilePath = "C:\Windows\Temp\JLStartupTemplate-04022024.log"  # Path to the log file
### Backup existing JL.dotm from C:\Program Files\Microsoft Office\root\Office16\STARTUP to C:\jltools\JLTemplates\JLStartupTemplateBackup
Copy-Item -Path "C:\Program Files\Microsoft Office\root\Office16\STARTUP\JL.dotm" -Destination "C:\jltools\JLtemplates\JLStartupTemplateBackup" -Force -ErrorAction SilentlyContinue
$logMessage = "JL.dotm copied from C:\Program Files\Microsoft Office\root\Office16\STARTUP to C:\jLtools\JLTemplates\JLStartupTemplateBackup on $(Get-Date)"
Remove-Item -Path "C:\Program Files\Microsoft Office\root\Office16\STARTUP\JL.dotm" -Force -ErrorAction
$logMessage = "JL.dotm deleted from C:\Program Files\Microsoft Office\root\Office16\STARTUP on $(Get-Date)"
### Create detection
Remove-ItemProperty -Path HKLM:\Software\Intune -Name Remediation_JLStartupTemplate-Autopilot -Force -ErrorAction SilentlyContinue
$logMessage = "JLStartupTemplate for Autopilot app detection has been removed from HKLM:\Software\Intune with the deletion of string Remediation_JLStartupTemplate-Autopilot to remove its app detection on $(Get-Date)"
### Log file 
$logMessage | Out-File -FilePath $logFilePath -Append