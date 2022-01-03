Windows Registry Editor Version 5.00

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers" /v DisableWebPrinting /t REG_DWORD /d 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers" /v KMPrintersAreBlocked /t REG_DWORD /d 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers" /v RegisterSpoolerRemoteRpcEndPoint /t REG_DWORD /d 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PackagePointAndPrint" /v PackagePointAndPrintServerList /t REG_DWORD /d 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PackagePointAndPrint\ListofServers" /v jlprnt-e01.jacksonlewis.net /t REG_SZ /d jlprnt-e01.jacksonlewis.net
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PackagePointAndPrint\ListofServers" /v jlprnt-e02.jacksonlewis.net /t REG_SZ /d jlprnt-e02.jacksonlewis.net
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PackagePointAndPrint\ListofServers" /v jlprnt-w01.jacksonlewis.net /t REG_SZ /d jlprnt-w01.jacksonlewis.net
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PackagePointAndPrint\ListofServers" /v jlprnt-w02.jacksonlewis.net /t REG_SZ /d jlprnt-w02.jacksonlewis.net
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PackagePointAndPrint\ListofServers" /v jleqprt-e01.jacksonlewis.net /t REG_SZ /d jleqprt-e01.jacksonlewis.net
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PackagePointAndPrint\ListofServers" /v jleqprt-w01.jacksonlewis.net /t REG_SZ /d jleqprt-w01.jacksonlewis.net
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v Restricted /t REG_DWORD /d 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v TrustedServers /t REG_DWORD /d 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v InForest /t REG_DWORD /d 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v ServerList /t REG_SZ /d "jlprnt-E01.jacksonlewis.net;jlprnt-e02.jacksonlewis.net;jlprnt-w01.jacksonlewis.net;jlprnt-w02.jacksonlewis.net;jleqprt-e01.jacksonlewis.net;jleqprt-w01.jacksonlewis.net"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v NoWarningNoElevationOnInstall /t REG_DWORD /d 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v UpdatePromptSettings /t REG_DWORD /d 2