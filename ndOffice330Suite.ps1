#######################################################################################################################################################
### ndOffice 3.3.0 Suite Installers
#######################################################################################################################################################
### Set prompt location
Set-Location -Path "C:\jltools\ndOffice330Suite"
### ndClick Removal
cmd /c WMIC.exe product where "name like 'Netdocuments ndClick%'" call uninstall > C:\Windows\Temp\ndClick-Removal.log
### ndOffice app installations
$ndOffice="ndOfficeSetup.msi"
$ndOfficeARGs="/I $ndOffice /qn /l C:\Windows\Temp\ndOffice330-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndOfficeARGs -wait -nonewwindow
$ndMail="ndMailSetup.msi"
$ndMailARGs="/I $ndMail /qn /l C:\Windows\Temp\ndMail112-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailARGs -wait -nonewwindow
$ndMailFM="ndMailFolderMappingx64.msi"
$ndMailFMARGs="/I $ndMailFM /qn /l C:\Windows\Temp\ndMailFM8834-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailFMARGs -wait -nonewwindow
#######################################################################################################################################################
# Delete the scheduled task that runs this script on user logoff and log results
#######################################################################################################################################################
Unregister-ScheduledTask -TaskName "ndOffice330Suite" -Confirm:$false -Verbose 4>C:\Windows\Temp\ndOffice-ScheduledTask-Removed.log