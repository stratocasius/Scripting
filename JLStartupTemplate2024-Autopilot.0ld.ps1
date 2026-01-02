# Generate timestamp for log file
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$logFilePath = "C:\Windows\Temp\JL-Startup-Template-Autopilot-$timestamp.log"

# Start transcript
Start-Transcript -Path $logFilePath

# Define the source and destination paths
$sourcePath = ".\JL.dotm"
$destinationPath = "C:\Program Files\Microsoft Office\root\Office16\STARTUP\JL.dotm"

# Check if the source file exists
if (Test-Path $sourcePath) {
    try {
        # Copy the file to the destination, overwriting if it already exists
        Copy-Item -Path $sourcePath -Destination $destinationPath -Force -Verbose
        Write-Output "JL.dotm File copied successfully."

        # Calculate the SHA256 hash of the file
        $fileHash = Get-FileHash -Path $sourcePath -Algorithm SHA256
        Write-Output "SHA256 hash of JL.dotm: $($fileHash.Hash)"
    } catch {
        Write-Error "An error occurred while copying the file: $_"
    }
} else {
    Write-Error "Source file '$sourcePath' does not exist."
}

# Stop transcript
Stop-Transcript
