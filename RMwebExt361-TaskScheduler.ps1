#######################################################################################################################################################
### ResearchMonitor RM Extension Files 3.6.1.629 - 03/10/2025
#######################################################################################################################################################
### Establish transcript
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\RMWebExtension361.log"
### Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\RMWebExtension361-ScheduledTask.log"
### Create C:\jltools\ResearchMonitor\RMWebExtension361 directory and copy over files.
New-Item -ItemType Directory -Path "C:\jltools\ResearchMonitor\RMWebExtension361" -Force -Verbose
Copy-Item .\*.* -Destination "C:\jltools\ResearchMonitor\RMWebExtension361" -Force -Verbose
#######################################################################################################################################################
### Scheduled Task created with trigger set to run script once device startup occurs. Task name - RMWebExt361
#######################################################################################################################################################
$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-ExecutionPolicy Bypass -File C:\jltools\ResearchMonitor\RMWebExtension361\RMWebExt361-INSTALL.ps1"

$Trigger = New-ScheduledTaskTrigger -AtStartup 

$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries 

Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -TaskName "RMWebExt361" -Description 'ResearchMonitor Extension 3.6.1.629' -User 'System' -Force -Verbose
### Transcription ends.
Stop-Transcript

exit 3010
