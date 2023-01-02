### Litera Metadact Removal
cmd /c WMIC.exe product where "name like 'Metadact%'" call uninstall > C:\Windows\Temp\Metadact-Removal.log
### Deletes custom .plf files.
Remove-Item -path "C:\Programdata\Litera\CorporateCleaningProfiles" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
