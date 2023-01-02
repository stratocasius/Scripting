### InterAction Windows Client Installation - 11/22/2022
### IAWCI.ps1
### MS ODBC 17 for SQL Server Install
$IAodbc="msodbcsql.msi"
$IAodbcARGs="/I $IAodbc /qn IACCEPTMSODBCSQLLICENSETERMS=YES /l c:\Windows\Temp\IA7-WCIodbc-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $IAodbcARGs -wait -nonewwindow
### InterAction Windows Client Install 
$IAWCI="InterActionDesktopApplications.msi"
$IAWCIARGs="/I $IAWCI /qn API_SERVER_NAME=http://jliaas-e01/jacksonlewis/home /qn /l c:\Windows\Temp\IADesktopWCI-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $IAWCIARGs -wait -nonewwindow
### Copies IntrActn.ini to "C:\ProgramData\LexisNexis\InterAction\Installation Data"
Copy-Item -path .\IntrActn.ini -Destination "C:\ProgramData\LexisNexis\InterAction\Installation Data" -Force -Verbose -ErrorAction SilentlyContinue
Copy-Item -path .\IAWebClientURL.ini -Destination "C:\Program Files (x86)\LexisNexis\InterAction\Desktop Integration\" -Force -Verbose -ErrorAction SilentlyContinue
### Registry additions
regedit.exe /s .\SystemDefaultTLSVersions.reg