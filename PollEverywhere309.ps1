### PollEverywhere app installations
$PollEverywhere="PollEverywhere.Everyone.msi"
$PollEverywhereARGs="/I $ndOffice /qn /l C:\Windows\Temp\PollEverywhere309-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndOfficeARGs -wait -nonewwindow