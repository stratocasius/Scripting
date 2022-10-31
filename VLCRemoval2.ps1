& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'VLC%'" call uninstall > C:\Windows\Temp\VLC-Removal.log
& cmd /c C:\windows\SysWOW64\wbem\WMIC.exe product where "name like 'VLC%'" call uninstall > C:\Windows\Temp\VLCx64-Removal.log
