### InterAction Admin Installation - 11/15/2022
### MS ODBC 17 for SQL Server Install
$IAodbc="msodbcsql.msi"
$IAodbcARGs="/I $IAodbc /qn IACCEPTMSODBCSQLLICENSETERMS=YES /l c:\Windows\Temp\IA7-IAAdminODBC-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $IAodbcARGs -wait -nonewwindow
### InterAction Admin Install
$IAAdmin="InterActionAdministratorTools.msi"
$IAAdminARGs="/I $IAAdmin /qn API_SERVER_NAME=JLIA-AS2-E01.jacksonlewis.net /qn /l c:\Windows\temp\IAAdmin-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $IAAdminARGs -wait -nonewwindow
### Copies IntrActn.ini to "C:\ProgramData\LexisNexis\InterAction\Installation Data"
Copy-Item -path .\iaadmin.ini -Destination "C:\ProgramData\LexisNexis\InterAction\Installation Data" -Force -Verbose