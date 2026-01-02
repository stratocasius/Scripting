### TeamViewer Host 15.59.3 - 11/01/2024
$installLogFilePath = "C:\programdata\Microsoft\IntuneManagementExtension\Logs\TeamViewerHost15.59.3-INSTALL.log"

# Install TeamViewer Host 15.59.3 and installation logging to %PROGRAMDATA\Microsoft\IntuneManagementExtension\Logs\TeamViewerHost15.59.3-INSTALL.log
Write-Output "Installing TeamViewer Host 15.59.3 with auto-update and deferred update channel settings. Safe Upgrade times are set during install for 7pm through 5am only."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"TeamViewer_Host.msi`" CUSTOMCONFIGID=`"6gt8mb3`" APITOKEN=`"16621801-TN3BCQXdDOAjbSLrq3C0`" ASSIGNMENTOPTIONS=`"--grant-easy-access --reassign`" /norestart /qn /l*v `"$installLogFilePath`"" -Wait -NoNewWindow
Write-Output "TeamViewer Host 15.59.3 installation and configuration complete. Logs created at $installLogFilePath."