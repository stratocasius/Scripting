### Intapp Time 7.2.1 for PreProvisioning - 02/22/2025
$installLogFilePath = "C:\programdata\Microsoft\IntuneManagementExtension\Logs\IntappTime7.2.1PreProvisioning-Transcript.log"
Start-Transcript $installLogFilePath
# Install Intapp Time 7.2.1 and installation logging to %PROGRAMDATA\Microsoft\IntuneManagementExtension\Logs\IntappTime7.2.1-INSTALL.log
Write-Output "Installing Intapp Time 7.2.1 with auto-update and deferred update channel settings. Safe Upgrade times are set during install for 7pm through 5am only."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"IntappTimeSetup721.msi`" /qn /l*v `"C:\programdata\Microsoft\IntuneManagementExtension\Logs\IntappTime7.2.1-INSTALL.log`"" -Wait -NoNewWindow
Write-Output "Intapp Time 7.2.1 installation complete. Logs created at C:\programdata\Microsoft\IntuneManagementExtension\Logs\IntappTime7.2.1-INSTALL.log."

### Install of Intapp Desktop Extension 7.2.1
### syntax from bat file
& cmd /c setup64.exe /verysilent /DEDestinationDirectory="C:\Program Files\Intapp\Desktop Extension" /TBAPIServiceURL="https://time.jacksonlewis.com:8080/APIService" /LaunchDE=false /CreateDEStartMenuShortcut=false /CreateTBStartMenuShortcut=false /Log=C:\programdata\Microsoft\IntuneManagementExtension\Logs\IntappDEx64PreProvisioning-INSTALL.log

### hosts.cfg file Update
Rename-Item -Path "C:\Program Files (x86)\Intapp\Time\hosts.cfg" -NewName "hosts.old" -Force -Verbose
Write-Output "Original hosts.cfg file renamed to hosts.old"
Copy-Item .\hosts.cfg -Destination "C:\Program Files (x86)\Intapp\Time" -Force -Verbose
Write-Output "Updated hosts.cfg placed at C:\Program Files x86\Intapp\Time\"
Stop-Transcript