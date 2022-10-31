$AdminAccountCredential = Get-Credential
$service = Get-WmiObject Win32_Service -Filter "Name='IntuneManagementExtension'" -ComputerName DT2713 -Credential $AdminAccountCredential
$service.StopService()
$service.StartService()