### Litera Metadact 5.10.0 05/23/2023
### Standalone with custom .xml files(modified 05/10/2023)
### Removal of any version of Litera Metadact
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Litera Metadact%'" call uninstall > C:\Windows\Temp\LiteraMetadact-Removal.log
### Exclude C:\Windows\System32\rundll32.exe from AV
$exceptionPath = "C:\Windows\SysWOW64\msiexec.exe"
Set-MpPreference -ControlledFolderAccessAllowedApplications $exceptionPath -Verbose
$LiteraMetadact = "Metadact.msi"
$LiteraMetadactARGs = "/I $LiteraMetadact LICENSEKEY=MD-300Iw2l-ST0-X-Q8169 ACCEPT_EULA_AND_TPLA=1 REBOOT=ReallySuppress MSIRESTARTMANAGERCONTROL=Disable /qn /l C:\Windows\Temp\LiteraMetadact5.10.0-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraMetadactARGs -wait -nonewwindow
Remove-MpPreference -ControlledFolderAccessAllowedApplications $exceptionPath -Verbose
Set-MpPreference -EnableControlledFolderAccess Enabled -Verbose
### Metadact's custom .xml files
Copy-Item -path .\*.xml -Destination "C:\Programdata\Litera\Customize" -Recurse -Force -ErrorAction SilentlyContinue