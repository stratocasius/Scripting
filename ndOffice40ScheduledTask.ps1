#######################################################################################################################################################
### ndOffice 4.0 Suite Install using Task Scheduler - 07/25/2024
### Create jltools directory
#######################################################################################################################################################
New-Item -ItemType Directory -Path "C:\jltools\ndOffice40Suite" -Force -Verbose
Copy-Item .\*.* -Destination "C:\jltools\ndOffice40Suite" -Force -Verbose
#######################################################################################################################################################
### Scheduled Task created with trigger set to sign off eventID 4634 - Task name - ndOffice40Suite
#######################################################################################################################################################
#$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-ExecutionPolicy Bypass -File C:\jltools\ndOffice40Suite\ndOffice40Suite.ps1"
#$CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
$Trigger = New-ScheduledTaskTrigger -AtStartup
#$Trigger.Subscription =
#@"
#<QueryList><Query Id="0" Path="Security"><Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and EventID=6005]]</Select></Query></QueryList>
#"@
#$Trigger.Enabled = $True 
#Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "ndOffice40Suite" -Description 'ndOffice40Suite' -User 'System' -Force -Verbose 4>C:\Windows\Temp\ndOffice40Suite-ScheduledTask-Created.log
$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-ExecutionPolicy Bypass -File C:\jltools\ndOffice40Suite\ndOffice40Suite.ps1"

$Trigger = New-ScheduledTaskTrigger -AtStartup 

$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries 

Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -TaskName "ndOffice40Suite" -Description 'ndOffice40Suite' -User 'System' -Force -Verbose 4>C:\Windows\Temp\ndOffice40Suite-ScheduledTask-Created.log



exit 3010