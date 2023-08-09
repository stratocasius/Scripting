$ProgressPreference = 'SilentlyContinue'
$Install_command = "c:\temp\npp-latest.exe"
$Install_arguements = "/S"
$installer_url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.4/npp.8.5.4.Installer.x64.exe"
$Save_location = "c:\temp\npp-latest.exe"
$min_install_file_size= 1MB # 1 Megabyte

$logFile = "c:\windows\temp\notepadpp_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log"

# Check if Notepad is installed
$installed = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
    Get-ItemProperty |
    Where-Object { $_.DisplayName -like "Notepad*" }

# If not installed, exit with code 0
if ($installed -eq $null) {
    "Notepad not installed. Exiting..." | Out-File -Append -FilePath $logFile
    exit 0
}

# Display current installed version
"Current installed version(s) of Notepad++:" | Out-File -Append -FilePath $logFile
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
"Uninstalling existing versions..." | Out-File -Append -FilePath $logFile
$uninstallStrings = $installed | ForEach-Object { $_.UninstallString }

foreach($uninstallString in $uninstallStrings)
{
    Start-Process cmd -ArgumentList "/c $uninstallString /S" -Wait
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
    Where-Object { $_.DisplayName -like "Notepad*" } |
    ForEach-Object { "$($_.DisplayName), $($_.DisplayVersion)" }

$installed_versions | Out-File -Append -FilePath $logFile
