### Unquoted path fix
& cmd /c reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Visual Studio 2010 Tools for Office Runtime (x64)" /v UninstallString /t REG_SZ /d '"c:\Program Files\Common Files\Microsoft Shared\VSTO\10.0\Microsoft Visual Studio 2010 Tools for Office Runtime (x64)\install.exe"' /f
& cmd /c reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Visual Studio 2010 Tools for Office Runtime (x64)" /v UninstallPath /t REG_SZ /d '"c:\Program Files\Common Files\Microsoft Shared\VSTO\10.0\Microsoft Visual Studio 2010 Tools for Office Runtime (x64)\install.exe"' /f