### SecureConnector Service Removal Remediation - 08/24/2024
# Define the log file path
$logFile = "C:\windows\temp\SecureConnectService-Removal.log"

# Initialize log content
$logContent = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Starting SecureConnector removal script.`r`n"

# Check if the SecureConnector process is running
$process = Get-Process -Name "SecureConnector" -ErrorAction SilentlyContinue

if ($process) {
    # If process found, log the detection
    $logContent += "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - SecureConnector process found.`r`n"
            
    try {
        # Stop the process
        Stop-Process -Name "SecureConnector" -Force -Verbose -ErrorAction Stop
        Write-output "SecureConnector process successfully stopped on $(get-date) for $env:COMPUTERNAME"
        $logContent += "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - SecureConnector process stopped successfully on $(get-date) for $env:COMPUTERNAME.`r`n"
    } catch {
        # Log any error that occurs while stopping the process
        $logContent += "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error stopping SecureConnector process: $_. on $(get-date) for $env:COMPUTERNAME.`r`n"
        Write-output "SecureConnector process could not be stopped on $(get-date) for $env:COMPUTERNAME."
    }
}

# Write log content to the file
$logContent | Out-File -FilePath $logFile -Append -Encoding utf8