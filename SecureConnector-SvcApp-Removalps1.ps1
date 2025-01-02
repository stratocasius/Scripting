### SecureConnector Service Removal Remediation - 08/25/2024
# Define the log file path
$logFile = "C:\windows\temp\SecureConnect-ServiceApp-Removal.log"

# Initialize log content
$logContent = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Starting SecureConnector removal script.`r`n"

# Check if the SecureConnector process is running
$process = Get-Process -Name "SecureConnector" -ErrorAction SilentlyContinue

# Define the uninstall command
$uninstallCommand = '"C:\Program Files\ForeScout SecureConnector\SecureConnector.exe" -uninstall -silent'

try {
    # Stop the process
        Stop-Process -Name "SecureConnector" -Force -Verbose -ErrorAction Stop
        Write-output "SecureConnector process successfully stopped on $(get-date) for $env:COMPUTERNAME"
        $logContent += "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - SecureConnector process stopped successfully on $(get-date) for $env:COMPUTERNAME.`r`n"
        $filePath = "C:\Program Files\ForeScout SecureConnector\SecureConnector.exe"
    # Run the uninstall command
    $logContent += "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Executing command: $uninstallCommand.`r`n"

    $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCommand" -Wait -NoNewWindow -PassThru

    # Capture the exit code
    if ($process.ExitCode -eq 0) {
        $logContent += "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - SecureConnector uninstalled successfully.`r`n"
    } else {
        $logContent += "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - SecureConnector uninstallation failed with exit code: $($process.ExitCode).`r`n"
    }
}

# Write log content to the file
$logContent | Out-File -FilePath $logFile -Append -Encoding utf8



