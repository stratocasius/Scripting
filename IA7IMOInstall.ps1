### InterAction 7 IMO with ODBC 17.
### MS ODBC 17 for SQL Server Install
$IAodbc="msodbcsql.msi"
$IAodbcARGs="/I $IAodbc /qn IACCEPTMSODBCSQLLICENSETERMS=YES /l c:\Windows\Temp\IA7-IAodbc-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $IAodbcARGs -wait -nonewwindow
### InterAction 7 IMO Installer
$IAIMO7='"LexisNexis InterAction for Microsoft Outlook.msi"'
$IAIMO7ARGs="/I $IAIMO7 /qn API_SERVER_NAME=https://JLIA-REST-E01.jacksonlewis.net /l c:\Windows\Temp\IA7-IMO-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $IAIMO7ARGs -wait -nonewwindow
### .Net 3.0 Registry edits 
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SchUseStrongCrypto /t REG_DWORD /d 1 /f /reg:32
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:32
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SchUseStrongCrypto /t REG_DWORD /d 1 /f /reg:64
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:64
### .Net 2.0 Registry edits 
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v2.0.50727 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:32
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v2.0.50727 /v SchUseStrongCrypto /t REG_DWORD /d 1 /f /reg:32
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v2.0.50727 /v SystemDefaultTlsVersions /t REG_DWORD /d 1 /f /reg:64
reg add HKLM\SOFTWARE\Microsoft\.NETFramework\v2.0.50727 /v SchUseStrongCrypto /t REG_DWORD /d 1 /f /reg:64
### TLS 1.2 Client and Server Registry edits 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v DisabledByDefault /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v Enabled /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" /v DisabledByDefault /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" /v Enabled /t REG_DWORD /d 1 /f