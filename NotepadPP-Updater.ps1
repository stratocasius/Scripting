$ProgressPreference "SilentlyContinue"
$Install_command = "c:\temp\npp-latest.exe"
$Install_arguements = "/S"
$installer_url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.3/npp.8.5.3.Installer.x64.exe"
$Save_location = "c:\temp\npp-latest.exe"
$min_install_file_size= 1MB # 1 Megabyte

 

# Download the installer
Write-Output "Downloading the installer..."
Invoke-WebRequest -Uri $installer_url -OutFile $Save_location

 

# Check file size
$file_size = (Get-Item $Save_location).length

 

# If file size is less than the minimum required, exit with code 1
if ($file_size -lt $min_install_file_size) {
    Write-Output "Error: Downloaded file size is less than the minimum required. Exiting..."
    exit 1
}

 

# Uninstall all existing versions
Write-Output "Uninstalling existing versions..."
$uninstallStrings = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
                    Get-ItemProperty |
                    Where-Object { $_.DisplayName -match "Notepad++" } |
                    ForEach-Object { $_.UninstallString }

 

foreach($uninstallString in $uninstallStrings)
{
    Start-Process cmd -ArgumentList "/c $uninstallString /S" -Wait
}

 

# Install the application
Write-Output "Installing the application..."
Start-Process -FilePath $Install_command -ArgumentList $Install_arguements -Wait

 

# Delete the installer
Remove-Item -Path $Save_location

 

# List installed versions
Write-Output "Listing installed versions..."
Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
    Get-ItemProperty |
    Where-Object { $_.DisplayName -match "Notepad++" } |
    ForEach-Object { Write-Output $_.DisplayName }