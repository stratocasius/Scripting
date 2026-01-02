### ndOffice 4.0.1 Suite Removal - 10/03/2024
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Netdocuments ndOffice'" call uninstall > C:\Windows\Temp\ndOffice-Removal.log
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Netdocuments ndMail Folder Mapping'" call uninstall > C:\Windows\Temp\ndMailFM-Removal.log
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Netdocuments ndMail'" call uninstall > C:\Windows\Temp\ndMail-Removal.log
& cmd /c "C:\ProgramData\Package Cache\{f7595622-f27a-4d72-ac15-52e1bf658ce4}\ndOfficeSetup.exe" /uninstall /s /l C:\Windows\temp\ndOffice401Installer-Removal.log