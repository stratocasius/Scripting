# Generate timestamp for log file
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$logFilePath = "C:\Windows\Temp\JL-Startup-Template-Autopilot-$timestamp.log"

# Start transcript
Start-Transcript -Path $logFilePath

# Define the source and destination paths
$sourcePath = ".\JL.dotm"
$destinationPath = "C:\Program Files\Microsoft Office\root\Office16\STARTUP\JL.dotm"

# Initialize a variable to track the copy success
$fileCopied = $false

# Check if the source file exists
if (Test-Path $sourcePath) {
    try {
        # Copy the file to the destination, overwriting if it already exists
        Copy-Item -Path $sourcePath -Destination $destinationPath -Force -Verbose
        Write-Output "JL.dotm file copied successfully."
        $fileCopied = $true

        # Calculate the SHA256 hash of the file
        $fileHash = Get-FileHash -Path $sourcePath -Algorithm SHA256
        Write-Output "SHA256 hash of JL.dotm: $($fileHash.Hash)"
    } catch {
        Write-Error "An error occurred while copying the file: $_"
    }
} else {
    Write-Error "Source file '$sourcePath' does not exist."
}

# Only proceed with registry operations if the file was successfully copied
if ($fileCopied) {
    # Define the registry path and value details
    $regPath = "HKLM:\SOFTWARE\Intune"
    $valueName = "Remediation_JLStartupTemplate-Autopilot"
    $valueData = "04022024"

    # Check if the registry key exists
    if (-not (Test-Path $regPath)) {
        # Create the registry key
        New-Item -Path $regPath -Force | Out-Null
        Write-Output "Registry key created: $regPath"
    }

    # Check if the value exists, if not, create it
    if (-not (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue)) {
        Set-ItemProperty -Path $regPath -Name $valueName -Value $valueData
        Write-Output "Value '$valueName' set to '$valueData' in $regPath"
    } else {
        Write-Output "Value '$valueName' already exists in $regPath"
    }
} else {
    Write-Output "Registry operations skipped because the file copy was not successful."
}

# Stop transcript
Stop-Transcript
