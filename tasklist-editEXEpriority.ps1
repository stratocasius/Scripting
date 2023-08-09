
### 
tasklist /FI "ImageName eq MsMpEng.exe"
wmic process where ProcessId=6364 CALL setpriority "64"



$processName = "ndOffice.exe"
$priorityLevel = "64"

$process = Get-WmiObject Win32_Process -Filter "name = '$processName'"
$processId = $process.ProcessId

$null = Start-Process -FilePath "wmic" -ArgumentList "process where ProcessId=$processId CALL setpriority '$priorityLevel'" -NoNewWindow -Wait
