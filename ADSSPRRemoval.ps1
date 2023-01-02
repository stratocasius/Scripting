### ADSSPR Removal
cmd /c WMIC.exe product where "name like 'ADSelfService Plus Client Software%'" call uninstall > C:\Windows\Temp\ADSelfServicePasswordReset-Removal.log