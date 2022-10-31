### 
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Mozilla Thunderbird 60.6.1 (x86 en-US)%'" call uninstall > C:\Windows\Temp\MozillaThunderbird-Removal.log
& cmd /c C:\windows\SysWOW64\wbem\WMIC.exe product where "name like 'Mozilla Thunderbird%'" call uninstall > C:\Windows\Temp\MozillaThunderbirdx64-Removal.log