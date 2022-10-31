Stop-Process -Name winword -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name outlook -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name excel -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name powerpnt -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name chrome -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name msedge -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name ndOffice -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name NetDocuments.ndMail.Application -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name ndClickWinTray -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name powerPDF -Force -Verbose -ErrorAction SilentlyContinue

cmd /c WMIC.exe product where "name like 'Netdocuments ndClick%'" call uninstall > C:\Windows\Temp\ndClick-Removal.log
$ndOffice="ndOfficeSetup.msi"
$ndOfficeARGs="/I $ndOffice /qn /l C:\Windows\Temp\ndOffice310-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndOfficeARGs -wait -nonewwindow
$ndMail="ndMailSetup.msi"
$ndMailARGs="/I $ndMail /qn /l C:\Windows\Temp\ndMail111-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailARGs -wait -nonewwindow
$ndMailFM="ndMailFolderMappingx64.msi"
$ndMailFMARGs="/I $ndMailFM /qn /l C:\Windows\Temp\ndMailFM7824-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailFMARGs -wait -nonewwindow
Restart-Computer -Force


