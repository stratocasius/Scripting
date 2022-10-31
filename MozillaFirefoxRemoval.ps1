& cmd /c 'C:\Program Files\Mozilla Firefox\uninstall\helper.exe' /S
& cmd /c 'C:\Program Files (x86)\Mozilla Maintenance Service\helper.exe' /S
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Firefox%'" call uninstall > C:\Windows\Temp\Firefox-Removal.log
& cmd /c C:\Windows\SysWow64\wbem\WMIC.exe product where "name like 'Firefox%'" call uninstall > C:\Windows\Temp\Firefox64x-Removal.log
