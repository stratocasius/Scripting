$logName = 'Microsoft-Windows-PrintService/Operational'
$eventID = 307  # Change this to the desired event ID
$searchString = 'through port IPP'  # Replace with the desired string to search

$events = Get-WinEvent -LogName $logName -FilterXPath "*[System[EventID=$eventID]]" -MaxEvents 10

$matchingEvents = $events | Where-Object { $_.Message -like "*$searchString*" }

if ($matchingEvents.Count -gt 0) {
    # Report matching events
    $matchingEvents | Select-Object -Property TimeCreated, Message
} else {
    # Report that no Azure printing events were found
    Write-Output "No Azure printing events found."
}