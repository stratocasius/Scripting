# Define the product code and log file path
$productCode = "{EB61453D-A6D4-429C-A7C7-3BFE15A2D535}"
$logFilePath = "C:\Windows\Temp\IA-IMO-7.01.01.11-LogMsg.log"

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
Log-Message "Starting check for product code $productCode."
# Function to check if the product code is installed
function Test-ProductCode {
    param (
        [string]$productCode
    )
    $uninstallKey = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    $installed = Get-ChildItem $uninstallKey | Get-ItemProperty | Where-Object { $_.PSChildName -eq $productCode }
    return $installed -ne $null
}
# Check if the product code is installed
if (Test-ProductCode -productCode $productCode) {
    Log-Message "Product code $productCode found. Initiating uninstallation."
    try {
        $uninstallCommand = "msiexec.exe /x $productCode /qn /l*v $logFilePath"
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $productCode /qn /l*v C:\Windows\Temp\IAIMO7-Removal.log" -Wait -NoNewWindow
        Log-Message "Successfully initiated uninstallation of application with product code $productCode."  
        reg.exe delete "HKLM\SOFTWARE\LexisNexis" /f
        Log-Message "Successfully removed registry key located at HKLM\SOFTWARE\LexisNexis from $env:COMPUTERNAME"
    } catch {
        Log-Message "Failed to uninstall application with product code $productCode. Error: $_"
    }
} else {
    Log-Message "Product code $productCode not found. No action taken."
}
# End logging
Log-Message "IA IMO 7.01 removal completed."