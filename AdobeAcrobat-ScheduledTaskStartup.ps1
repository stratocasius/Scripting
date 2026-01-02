#######################################################################################################################################################
### Adobe Acrobat 25.001 Install using Task Scheduler - 11/20/2025
#######################################################################################################################################################
### Create jltools directory - copy files.
#######################################################################################################################################################
New-Item -ItemType Directory -Path "C:\jltools\AdobeAcrobatSuite" -Force
Copy-Item .\*.* -Destination "C:\jltools\AdobeAcrobatSuite" -Force
#######################################################################################################################################################
### Scheduled Task created with trigger set to run script once device startup occurs. Task name - AdobeAcrobatSuite
#######################################################################################################################################################
$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-ExecutionPolicy Bypass -File C:\jltools\AdobeAcrobatSuite\AdobeAcrobatSuite-INSTALL.ps1"

$Trigger = New-ScheduledTaskTrigger -AtStartup 

$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries 

Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -TaskName "AdobeAcrobatSuite" -Description 'AdobeAcrobatSuite' -User 'System' -Force -Verbose 4>C:\Programdata\Microsoft\IntuneManagementExtension\Logs\AdobeAcrobatSuiteUpdate-ScheduledTask-Created.log

exit 3010