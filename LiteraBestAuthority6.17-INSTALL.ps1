### Litera Best Authority 6.17.0.14 Install - 09/02/2025

### Adding LevitJames.Register.exe to AV process exclusion
Write-Output "Adding LevitJames.Register.exe to antivirus exclusion list..."
Add-MpPreference -ExclusionProcess LevitJames.Register.exe
Write-Output "LevitJames.Register.exe added to antivirus exclusion list."

# Install Litera BestAuthority 6.15 and installation logging to %PROGRAMDATA%\Microsoft\IntuneManagementExtension\Logs\LiteraBestAuthority6.15-INSTALL.log
### Install log path
Write-Output "Installing BestAuthority with logging at %PROGRAMDATA%\Microsoft\IntuneManagementExtension\Logs\BestAuthority6.15-MSI-INSTALL.log"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"BestAuthority_6.15.0_x64.msi`" /qn LICENSEKEY=BA-300Iw2l-ST0-E-Q6F48 ACCEPT_EULA_AND_TPLA=1 ISINSTALLLITERATAB=1 /norestart /l*v `"C:\programdata\microsoft\IntuneManagementExtension\Logs\LiteraBestAuthority6.15-INSTALL.log" -Wait -NoNewWindow
Write-Output "BestAuthority 6.15 installation and configuration complete on $(Get-Date)."

### Remove AV exclusion 
### Log message before removing LevitJames.Register.exe to AV process exclusion
Write-Output "Removing LevitJames.Register.exe to antivirus exclusion list..."
Remove-MpPreference -ExclusionProcess LevitJames.Register.exe 
Write-Output "LevitJames.Register.exe removed from antivirus exclusion list."

# End transcript
Stop-Transcript