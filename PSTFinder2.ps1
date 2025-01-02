# Define the product code and log file path
$logFilePath = "C:\programdata\microsoft\IntuneManagementExtensions\Logs\PSTFinderResults.log"

# Function to log messages to the log file
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFilePath -Value $logMessage
}
# Start logging
Log-Message "Checking for existing .PST files locally..."

# Specify the root directory to search for .pst files
$rootDirectory = "C:\"

# Specify the search pattern for .pst files
$searchPattern = "*.pst"

# Perform the search and write the names and locations of .pst files using Write-Output
Get-ChildItem -Path $rootDirectory -File -Recurse -Filter $searchPattern | ForEach-Object {
    Log-Message "Found .PST named $($_.Name) located at $($_.FullName)"
    Write-Output "Name: $($_.Name)"
    Write-Output "Location: $($_.FullName)"
}