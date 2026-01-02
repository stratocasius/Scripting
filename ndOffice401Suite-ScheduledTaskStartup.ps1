#######################################################################################################################################################
### ndOffice 4.0.1 Suite Install using Task Scheduler - 10/03/2024
#######################################################################################################################################################
### Create jltools directory - copy files.
#######################################################################################################################################################
New-Item -ItemType Directory -Path "C:\jltools\ndOffice401Suite" -Force -Verbose
Copy-Item .\*.* -Destination "C:\jltools\ndOffice401Suite" -Force -Verbose
#######################################################################################################################################################
### Scheduled Task created with trigger set to run script once device startup occurs. Task name - ndOffice401Suite
#######################################################################################################################################################
$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-ExecutionPolicy Bypass -File C:\jltools\ndOffice401Suite\ndOffice401Suite-Install.ps1"

$Trigger = New-ScheduledTaskTrigger -AtStartup 

$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries 

Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -TaskName "ndOffice401Suite" -Description 'ndOffice401Suite' -User 'System' -Force -Verbose 4>C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndOffice401Suite-ScheduledTask-Created.log

exit 3010