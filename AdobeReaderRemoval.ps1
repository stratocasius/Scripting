& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Adobe Reader%'" call uninstall > C:\Windows\Temp\AdobeReader-Removal.log