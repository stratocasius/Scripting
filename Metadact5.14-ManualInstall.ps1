### Litera Metadact 5.14 - Manual Installer 06/17/2024
### Standalone with custom .xml files(modified 05/10/2023) - Added removal of Low.pfl, High.pfl
### Exclude C:\Windows\SysWOW64\rundll32.exe from AV
$exceptionPath = "C:\Windows\SysWOW64\msiexec.exe"
Set-MpPreference -ControlledFolderAccessAllowedApplications $exceptionPath -Verbose
# Set-MpPreference -ControlledFolderAccessAllowedApplications $exceptionPath -Force
$LiteraMetadact = "Metadact.msi"
$LiteraMetadactARGs = "/I $LiteraMetadact LICENSEKEY=MD-300Iw2l-ST0-X-Q8169 ACCEPT_EULA_AND_TPLA=1 REBOOT=ReallySuppress MSIRESTARTMANAGERCONTROL=Disable /qn /l C:\Windows\Temp\LiteraMetadact5.14Manual-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraMetadactARGs -wait -nonewwindow
Remove-MpPreference -ControlledFolderAccessAllowedApplications $exceptionPath
Set-MpPreference -EnableControlledFolderAccess Enabled -Force
### Metadact's custom .xml files
Copy-Item -path .\*.xml -Destination "C:\Programdata\Litera\Customize" -Recurse -Force -ErrorAction SilentlyContinue
Set-Location -Path "C:\ProgramData\Litera\CorporateCleaningProfiles\"
Remove-Item -Path "C:\ProgramData\Litera\CorporateCleaningProfiles\High.pfl" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\ProgramData\Litera\CorporateCleaningProfiles\Low.pfl" -Force -ErrorAction SilentlyContinue