### Zoom(x64) Update Script - 12/29/2023
### Looks for any Zoom(x64) displayName in HKLM:\SW\MS\Win\CV\Uinstall and downloads the latest, removes older and installs latest version available silently.
### Note: MSIRestartManagerControl=Disable switch prevents update if Zoom meeting is currently in progress.

$ProgressPreference = 'SilentlyContinue'
$Install_command = "c:\Windows\temp\zoom64-latest.msi"
$Install_arguements = "/qn /norestart MSIRestartManagerControl=Disable /l C:\Windows\Temp\Zoom5.17x64-INSTALL.log"
$installer_url = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64"
$Save_location = "c:\Windows\temp\zoom64-latest.msi"
$min_install_file_size= 1MB # 1 Megabyte

$logFile = "c:\windows\temp\Zoom64-INSTALL_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log"

# Check if Notepad is installed
$installed = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
    Get-ItemProperty |
    Where-Object { $_.DisplayName -like "Zoom(64bit)*"}

# If not installed, exit with code 0
if ($installed -eq $null) {
    "Zoom (x64) not installed. Exiting..." | Out-File -Append -FilePath $logFile
    exit 0
}

# Display current installed version
"Current installed version(s) of Zoom (64-bit):" | Out-File -Append -FilePath $logFile
$installed_versions = $installed | ForEach-Object { "$($_.DisplayName), $($_.DisplayVersion)" }
$installed_versions | Out-File -Append -FilePath $logFile

# Download the installer
"Downloading the installer..." | Out-File -Append -FilePath $logFile
Invoke-WebRequest -Uri $installer_url -OutFile $Save_location

# Check file size
$file_size = (Get-Item $Save_location).length

# If file size is less than the minimum required, exit with code 1
if ($file_size -lt $min_install_file_size) {
    "Error: Downloaded file size is less than the minimum required. Exiting..." | Out-File -Append -FilePath $logFile
    exit 1
}

# Uninstall all existing versions 
# Consider switching to downloading the CleanInstaller.exe to remove all versions of Zoom(x64)
"Uninstalling existing versions..." | Out-File -Append -FilePath $logFile
$uninstallStrings = $installed | ForEach-Object { $_.UninstallString }

foreach($uninstallString in $uninstallStrings)
{
    Start-Process cmd -ArgumentList "/c $uninstallString /QN /l C:\Windows\Temp\ZoomX64-Removal.log" -Wait
}

# Install the application
"Installing the application..." | Out-File -Append -FilePath $logFile
Start-Process -FilePath $Install_command -ArgumentList $Install_arguements -Wait

# Delete the installer
Remove-Item -Path $Save_location

# List installed versions
"Listing installed versions..." | Out-File -Append -FilePath $logFile
$installed_versions = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
    Get-ItemProperty |
    Where-Object { $_.DisplayName -like "Zoom(x64)*"} |
    ForEach-Object { "$($_.DisplayName), $($_.DisplayVersion)" }

$installed_versions | Out-File -Append -FilePath $logFile