$logName = 'Microsoft-Windows-PrintService/Operational'
$eventID = 307  # Change this to the desired event ID
$searchString = 'through port IPP'  # Replace with the desired string to search

$events = Get-WinEvent -LogName $logName -FilterXPath "*[System[EventID=$eventID]]"

$filteredEvents = $events | Where-Object { $_.Message -like "*$searchString*" }

# Output the filtered events
$filteredEvents | Select-Object -Property TimeCreated, Message
