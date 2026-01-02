### Zoom Workspace 6.2.49050 - 11/01/2024
$installLogFilePath = "C:\programdata\Microsoft\IntuneManagementExtension\Logs\Zoom6.2.49050-INSTALL.log"

# Run CleanZoom with logging to remove any prior versions, logging to %PROGRAMDATA\Microsoft\IntuneManagementExtension\Logs\cleanzoom.log
Write-Output "Running CleanZoom to remove previous installations..."
Start-Process -FilePath "CleanZoom.exe" -ArgumentList "/silent" -Wait
copy-item .\cleanzoom.log C:\programdata\Microsoft\IntuneManagementExtension\Logs\

# Install Zoom with auto-update, safe time, Slow update channel, and installation logging to %PROGRAMDATA\Microsoft\IntuneManagementExtension\Logs\Zoom6.2.49050-INSTALL.log
Write-Output "Installing Zoom Workplace 6.2.49050 with auto-update and deferred update channel settings. Safe Upgrade times are set during install for 7pm through 5am only."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"ZoomInstallerFull.msi`" MSIRestartManagerControl=`"Disable`" ZoomAutoUpdate=`"true`" ZConfig=`"AU2_EnableAutoUpdate=1;AU2_SetUpdateChannel=1;AU2_SafeUpgradeTimeStart=19;AU2_SafeUpgradeTimeEnd=5`" /qn /l*v `"$installLogFilePath`"" -Wait -NoNewWindow
Write-Output "Zoom Workplace 6.2.49050 installation and configuration complete. Logs created at $installLogFilePath."
