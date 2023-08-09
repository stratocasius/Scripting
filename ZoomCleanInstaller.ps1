# Define the URLs and file paths
$zoomCleanURL = "https://support.zoom.us/hc/en-us/article_attachments/360084068792/CleanZoom.zip"
$zoomCleanZipPath = "C:\temp\ZoomClean.zip"
$zoomCleanExePath = "C:\temp\ZoomClean\ZoomClean.exe"

$zoomMSIURL = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64"
$zoomMSIPath = "C:\temp\ZoomInstallerFull.msi"

# Create the temp directory if not already exist
if(!(Test-Path -Path "C:\temp\" )) {
    Write-Output "Creating directory: C:\temp\"
    New-Item -ItemType directory -Path "C:\temp\"
}

# Download ZoomClean.zip
Write-Output "Downloading ZoomClean.zip"
Invoke-WebRequest -Uri $zoomCleanURL -OutFile $zoomCleanZipPath

# Extract ZoomClean.zip
Write-Output "Extracting ZoomClean.zip"
Expand-Archive -Path $zoomCleanZipPath -DestinationPath "C:\temp\"

# Check ZoomClean.exe size
Write-Output "Checking ZoomClean.exe size"
$zoomCleanExeSize = (Get-Item $zoomCleanExePath).Length / 1KB # Size in KB
if ($zoomCleanExeSize -lt 100) {
    Write-Output "Error: ZoomClean.exe size is less than 100KB"
    Exit 1
}

# Execute ZoomClean.exe
Write-Output "Executing ZoomClean.exe"
Start-Process -FilePath $zoomCleanExePath -Wait

# Download ZoomInstallerFull.msi
Write-Output "Downloading ZoomInstallerFull.msi"
Invoke-WebRequest -Uri $zoomMSIURL -OutFile $zoomMSIPath

# Check ZoomInstallerFull.msi size
Write-Output "Checking ZoomInstallerFull.msi size"
$zoomMSISize = (Get-Item $zoomMSIPath).Length / 1MB # Size in MB
if ($zoomMSISize -lt 10) {
    Write-Output "Error: ZoomInstallerFull.msi size is less than 10MB"
    Exit 1
}

# Silently install Zoom
Write-Output "Installing Zoom"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $zoomMSIPath, "/qn" -Wait

# Cleanup files
Write-Output "Cleaning up files"
Remove-Item -Path $zoomCleanZipPath
Remove-Item -Path $zoomCleanExePath -Recurse
Remove-Item -Path $zoomMSIPath

# List installed Zoom packages
Write-Output "Listing installed Zoom packages"
Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE (Name LIKE 'Zoom%')" | Format-List Name, Version
