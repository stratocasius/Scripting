#######################################################################################################################################################
### ndOffice 3.3.0 Suite Install using Task Scheduler - 07/06/2023
### Create jltools directory
#######################################################################################################################################################
New-Item -ItemType Directory -Path "C:\jltools\ndOffice330Suite" -Force -Verbose
Copy-Item .\*.* -Destination "C:\jltools\ndOffice330Suite" -Force -Verbose
#######################################################################################################################################################
### Scheduled Task created with trigger set to sign off eventID 4634 - Task name - ndOffice330Suite
#######################################################################################################################################################
$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-ExecutionPolicy Bypass -File C:\jltools\ndOffice330Suite\ndOffice330Suite.ps1"
$CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
$Trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
$Trigger.Subscription = 
@"
<QueryList><Query Id="0" Path="Security"><Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and EventID=4634]]</Select></Query></QueryList>
"@
$Trigger.Enabled = $True 
Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "ndOffice330Suite"  -Description 'ndOffice330Suite' -User 'System' -Force -Verbose 4>C:\Windows\Temp\ndOffice-ScheduledTask-Created.log