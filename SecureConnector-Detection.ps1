# Define the file path to check
$filePath = "C:\Program Files\ForeScout SecureConnector\SecureConnector.exe"

# Check if the file exists
if (Test-Path $filePath) {
    # If the file exists, exit with code 1
    Write-Output "SecureConnector service found!!!"
    exit 1
} else {
    # If the file does not exist, exit with code 0 (success)
    Write-Output "No SecureConnector service found on $env:COMPUTERNAME"
    exit 0
}
