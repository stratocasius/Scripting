### QuickTime - Apple App Support - Apple SOftware Update Removals
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Apple Application Support%'" call uninstall > C:\Windows\Temp\AppleAppSupport-Removal.log
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Apple Software Update%'" call uninstall > C:\Windows\Temp\AppleSoftwareUpdate-Removal.log
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'QuickTime%'" call uninstall > C:\Windows\Temp\QuickTime-Removal.log