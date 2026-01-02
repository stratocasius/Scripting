MsiExec.exe /X{AC76BA86-1033-FFFF-7760-BC15014EA700} /QN /L C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AdobeAcrobat25.1-Removal.log


### Things to delete:
Folders:
C:\Program Files\Adobe
C:\Program Files (x86)\Adobe

Scheduled Tasks:
#### Scheduled Task removal - Launch Adobe CCXProcess
Unregister-ScheduledTask -TaskName "Launch Adobe CCXProcess" -Confirm:$false
Write-Output "Task Scheduler item Launch Adobe CCXProcess removed on $(Get-Date)"
### StartMenu Tasks Removed.
Unregister-ScheduledTask -TaskName "StartMenu" -Confirm:$false
Write-Output "Task Scheduler item StartMenu removed on $(Get-Date)"
Unregister-ScheduledTask -TaskName "StartMenu2024" -Confirm:$false
Write-Output "Task Scheduler item StartMenu2024 removed on $(Get-Date)"

$AdobePro="{AC76BA86-1033-FFFF-7760-BC15014EA700}"
$AdobeProARGs="/X $AdobePro /qn /l C:\Programdata\Microsoft\IntuneManagementExtension\Logs\AdobeAcrobatPro-Uninstall.log"
Start-Process "C:\Program Files (x86)\Adobe\Adobe Creative Cloud\Utils\Creative Cloud Uninstaller.exe" -wait -nonewwindow
Write-Host "Removal of Adobe Creative Cloud completed at $(get-Date)."


Start-Process "msiexec.exe" -ArgumentList $AdobeProARGs -wait -nonewwindow
Write-Host "Removal of Adobe Acrobat Pro 25.001.20918 completed at $(get-Date)."

#### Adobe Genuine Service - 9.0.0.29 Uninstall
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\AdobeGenuineService
DisplayVersion - 9.0.0.29
UninstallString - "C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient\AdobeCleanUpUtility.exe"

### Added/Removed for SSO functionality?(Confirm)
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown
DWORD
iAcroLoginType
with a value of "5"