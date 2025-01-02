### ndOffice 4.0 Suite Removal - 007/25/2024
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Netdocuments ndOffice'" call uninstall > C:\Windows\Temp\ndOffice-Removal.log
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Netdocuments ndMail Folder Mapping'" call uninstall > C:\Windows\Temp\ndMailFM-Removal.log
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Netdocuments ndMail'" call uninstall > C:\Windows\Temp\ndMail-Removal.log
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Netdocuments ndClick%'" call uninstall > C:\Windows\Temp\ndClick-Removal.log
Start-Process "C:\ProgramData\Package Cache\{d61f20be-880a-4ccb-b411-a93723fca6c0}\ndOfficeSetup.exe" -ArgumentList "/uninstall", "/quiet" -NoNewWindow -Wait
Start-Process "C:\ProgramData\Package Cache\{9e22c423-32d4-42db-86c1-622ea0332eae}\ndMailSetup.exe" -ArgumentList "/uninstall", "/quiet" -NoNewWindow -Wait

