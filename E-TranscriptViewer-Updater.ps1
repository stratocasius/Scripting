### Real Legal E-Transcript Viewer 6.8.0.29
$ProgressPreference = "SilentlyContinue"
$Install_command = "c:\jltools\E-Transcript-LatestInstaller.exe"
$Install_arguements = "/S /v/qn"
$installer_url = "https://cdn.thomsonreuters.com/esd/software/eTranscript-Mgr/E-Transcript%20Bundle%20Viewer-6.8.0.29.exe"
$Save_location = "c:\jltools\E-Transcript-LatestInstaller.exe"
$min_install_file_size= 1MB # 1 Megabyte

# Download the installer
Write-Output "Downloading the installer..."
Invoke-WebRequest -Uri $installer_url -OutFile $Save_location -Verbose

# Check file size
$file_size = (Get-Item $Save_location).length

 # If file size is less than the minimum required, exit with code 1
if ($file_size -lt $min_install_file_size) {
    Write-Output "Error: Downloaded file size is less than the minimum required. Exiting..."
    exit 1
}

# Uninstall all existing versions
Write-Output "Uninstalling existing versions..."
$uninstallStrings = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall |
                    Get-ItemProperty |
                    Where-Object { $_.DisplayName -match "RealLegal E-Transcript Bundle Viewer" -and $_.DisplayVersion -lt "6.8.0.29"} |
                    ForEach-Object { $_.UninstallString }

foreach($uninstallString in $uninstallStrings)
{
    # Using WMIC for removal.    
    & cmd /c C:\Windows\SysWow64\wbem\WMIC.exe product where "name like 'RealLegal E-Transcript Bundle Viewer'" call uninstall /nointeractive > C:\Windows\Temp\E-Transcript-Removal.log
} 
# Install the application
Write-Output "Installing the application..."
Start-Process -FilePath $Install_command -ArgumentList $Install_arguements -Wait

# Delete the installer
Remove-Item -Path $Save_location
