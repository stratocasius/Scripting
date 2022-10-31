### MS SilverLight Removal(per Rapid7)
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Microsoft Silverlight%'" call uninstall > C:\Windows\Temp\MicrosoftSilverLight-Removal.log
& cmd /c C:\Windows\SysWow64\wbem\WMIC.exe product where "name like 'Microsoft Silverlight%'" call uninstall > C:\Windows\Temp\MicrosoftSilverLightX86-Removal.log

