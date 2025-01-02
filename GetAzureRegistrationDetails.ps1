# Get Azure Registration Details
$azureAdStatus = dsregcmd /status

# Extract the desired fields for console output
$ngcSet = $azureAdStatus | Where-Object { $_ -match "NgcSet\s+:\s+(\S+)" } | ForEach-Object { "NgcSet: " + $matches[1] }
$wamDefaultSet = $azureAdStatus | Where-Object { $_ -match "WamDefaultSet\s+:\s+(\S+)" } | ForEach-Object { "WamDefaultSet: " + $matches[1] }
$azureAdPrt = $azureAdStatus | Where-Object { $_ -match "AzureAdPrt\s+:\s+(\S+)" } | ForEach-Object { "AzureAdPrt: " + $matches[1] }
$deviceAuthStatus = $azureAdStatus | Where-Object { $_ -match "DeviceAuthStatus\s+:\s+(\S+)" } | ForEach-Object { "DeviceAuthStatus: " + $matches[1] }
$azureAdPrtExpiryTime = $azureAdStatus | Where-Object { $_ -match "AzureAdPrtExpiryTime\s+:\s+(.+)" } | ForEach-Object { "AzureAdPrtExpiryTime: " + $matches[1] }

# Display the fields to the console on a single line
$consoleOutput = "$ngcSet; $wamDefaultSet; $azureAdPrt; $deviceAuthStatus; $azureAdPrtExpiryTime"
Write-Output $consoleOutput

# Define the log filename based on current date and time
# $logFileName = "c:\windows\temp\azjoinstatus-" + (Get-Date -Format "yyyyMMddHHmmss") + ".log"

# Write everything to the log file
#$azureAdStatus | Out-File $logFileName -Append
