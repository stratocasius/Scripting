$keyPath = "HKEY_LOCAL_MACHINE\SOFTWARE\JL"
$stringName = "ZoomInstall05222023"

# Define the URLs and file paths
$zoomCleanURL = "https://support.zoom.us/hc/en-us/article_attachments/360084068792/CleanZoom.zip"
$zoomCleanZipPath = "C:\temp\CleanZoom.zip"
$zoomCleanExePath = "C:\temp\CleanZoom.exe"

$zoomMSIURL = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64"
$zoomMSIPath = "C:\temp\ZoomInstallerFull.msi"

# Create the temp directory if not already exist
if(!(Test-Path -Path "C:\temp\" )) {
    New-Item -ItemType directory -Path "C:\temp\"
}

# Download ZoomClean.zip
Invoke-WebRequest -Uri $zoomCleanURL -OutFile $zoomCleanZipPath

# Extract ZoomClean.zip
Expand-Archive -Path $zoomCleanZipPath -DestinationPath "C:\temp\"

# Execute ZoomClean.exe
Start-Process -FilePath $zoomCleanExePath -ArgumentList '/silent' -Wait

# Download ZoomInstallerFull.msi
Invoke-WebRequest -Uri $zoomMSIURL -OutFile $zoomMSIPath

# Silently install Zoom
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "$zoomMSIPath", "ZoomAutoUpdate=true", "zConfig=EnableSilentAutoUpdate=true;AU2_EnableAutoUpdate=1;AU2_SetUpdateChannel=1;AU2_SetUpdateSchedule=0000-2359", "/qn", "/l", "c:\windows\temp\Zoom51415434x64-INSTALL.log" -Wait

# Cleanup files
Remove-Item -Path $zoomCleanZipPath
Remove-Item -Path $zoomCleanExePath -Recurse
Remove-Item -Path $zoomMSIPath

$zoomExePath = "C:\Program Files\Zoom\bin\zoom.exe"
if (Test-Path -Path $zoomExePath) {
    # Zoom is installed, modify the registry

    reg add "$keyPath" /f /reg:64 
    reg add "$keyPath" /v "$stringName" /t REG_SZ /d "$stringName" /f /reg:64
}
