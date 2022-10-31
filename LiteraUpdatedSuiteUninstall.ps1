### Litera Updated Suite Removal - 10/18/2022
### Removed Litera Metadact from Suite and now is provided as a standalone app.
### Exclude Rundll32.exe process from AV
Add-MpPreference -ExclusionProcess rundll32.exe -Verbose
### Litera Compare Removal
cmd /c WMIC.exe product where "name like 'Litera Compare%'" call uninstall > C:\Windows\Temp\LiteraCompare-Removal.log
### Litera DocXtools Removal
cmd /c WMIC.exe product where "name like 'Litera DocXtools%'" call uninstall > C:\Windows\Temp\LiteraDocXTools-Removal.log
### Litera DocXtools Companion Removal
cmd /c WMIC.exe product where "name like 'Litera DocXtools Companion%'" call uninstall > C:\Windows\Temp\LiteraDocXToolsCompanion-Removal.log
### Litera Customization Removals
Remove-Item -path "C:\Programdata\Litera" -recurse -force -verbose
Remove-Item -path "$Env:LOCALAPPDATA\Microsystems" -recurse -force -verbose
Remove-Item -path "$Env:LOCALAPPDATA\Litera" -recurse -force -verbose
Remove-Item -path "$Env:APPDATA\Litera" -recurse -force -verbose
Remove-Item -path "$Env:APPDATA\Litera Microsystems" -recurse -force -verbose
Remove-Item -path "$Env:APPDATA\Microsystems" -recurse -force -verbose
### Remove exclusion from C:\Windows\System32\rundll32.exe from AV
Remove-MpPreference -ExclusionProcess rundll32.exe -Verbose