### Zoom Removal and file cleanup 05/17/2023
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Litera Metadact%'" call uninstall > C:\Windows\Temp\LiteraMetadact-Removal.log
Remove-Item -Path "C:\ProgramData\Litera\Customize\*.xml" -Recurse -Verbose -ErrorAction SilentlyContinue