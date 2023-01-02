### Litera Metadact Standalone with custom .pfl files(11/23/2022) and .mdxt(11/23/22)
### Exclude C:\Windows\System32\rundll32.exe from AV
Add-MpPreference -ExclusionProcess rundll32.exe -Verbose
### Metadact installer with arguements
$LiteraMetadact = "Metadact.msi"
$LiteraMetadactARGs = "/I $LiteraMetadact LICENSEKEY=MD-300Iw2l-ST0-X-Q8169 ACCEPT_EULA_AND_TPLA=1 REBOOT=ReallySuppress MSIRESTARTMANAGERCONTROL=Disable /qn /l C:\Windows\Temp\LiteraMetadact560-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraMetadactARGs -wait -nonewwindow
### Metadact's custom .pfl files 
Copy-Item -path .\*.pfl -Destination "C:\Programdata\Litera\CorporateCleaningProfiles" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
### Remove exclusion from C:\Windows\System32\rundll32.exe from AV
Remove-MpPreference -ExclusionProcess rundll32.exe -Verbose