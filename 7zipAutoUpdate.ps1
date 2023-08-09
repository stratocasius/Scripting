# Ensure running as an administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator."
    exit
}

# Define a timestamp for logging purposes
$timestamp = Get-Date -Format "yyMMddHHmmss"

# Create a log function for easier logging throughout the script
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    
    $logFile = "C:\Windows\Temp\7zipInstall_$timestamp.log"
    Add-Content -Path $logFile -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss"): $Message"
}

Write-Log "Starting 7-Zip installer script."

# Define the URL for 7-Zip downloads page
$url = "https://www.7-zip.org/download.html"

# Use Invoke-WebRequest to fetch the content of the page
$pageContent = Invoke-WebRequest -Uri $url

# Extract the MSI download link for x64 version using a regex pattern
$msiLink = $pageContent.Content | Select-String -Pattern 'href="(.*x64.msi)"' | ForEach-Object { $_.Matches[0].Groups[1].Value }

# If no link is found, exit with an error
if (-not $msiLink) {
    Write-Log "Failed to find the download link for 7-Zip x64 MSI."
    exit
}

# Construct the full download link
$downloadLink = "https://www.7-zip.org/$msiLink"

# Download the MSI to a temp location
$msiFilePath = "$env:TEMP\7zip_latest_x64.msi"
Write-Log "Downloading 7-Zip from $downloadLink."
Invoke-WebRequest -Uri $downloadLink -OutFile $msiFilePath

# Install 7-Zip using the downloaded MSI
$msiLogPath = "C:\Windows\Temp\7zipMSIInstall_$timestamp.log"
Write-Log "Installing 7-Zip. MSI log will be saved to $msiLogPath."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiFilePath`" /qn /l* `"$msiLogPath`"" -Wait

# Clean up the downloaded MSI
Remove-Item $msiFilePath
Write-Log "Cleaned up the downloaded MSI file."

Write-Log "7-Zip installation completed!"