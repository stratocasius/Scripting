# Define the event log path and relevant Event IDs
$logPath = "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin"
$eventIDs = @(201, 202, 204, 205, 208)

# Get the events from the event log
$events = Get-WinEvent -LogName $logPath | Where-Object { $eventIDs -contains $_.Id }

# Display the events
$events | Format-Table -AutoSize -Property Id, TimeCreated, Message

# Define the path to the IntuneManagementExtension log file
$logFilePath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log"

# Check if the log file exists
if (Test-Path $logFilePath) {
    # Read the log file
    $logContent = Get-Content -Path $logFilePath

    # Define a pattern to search for entries related to configuration profiles
    $pattern = "Policy.*successfully applied|Sync.*completed"

    # Parse the log file for relevant entries
    $parsedEntries = $logContent | Select-String -Pattern $pattern

    # Display the parsed entries
    if ($parsedEntries) {
        Write-Output "Relevant log entries found:"
        $parsedEntries | ForEach-Object {
            [PSCustomObject]@{
                TimeStamp = ($_ -match '^\[(.*?)\]') ? $matches[1] : ""
                Message   = $_
            }
        } | Format-Table -AutoSize -Property TimeStamp, Message
    } else {
        Write-Output "No relevant log entries found."
    }
} else {
    Write-Output "Log file not found at path: $logFilePath"
}
