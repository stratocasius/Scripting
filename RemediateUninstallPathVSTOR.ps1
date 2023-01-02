### Direct Registry edit to remediate HKLM:
### UninstallString 
Set-Location -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Visual Studio 2010 Tools for Office Runtime (x64)"
$newValueString = "`"c:\Program Files\Common Files\Microsoft Shared\VSTO\10.0\Microsoft Visual Studio 2010 Tools for Office Runtime (x64)\install.exe`""
Set-ItemProperty -Path . -Name UninstallString -Value $newValueString -Verbose -ErrorAction SilentlyContinue

### UninstallPath
Set-Location -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Visual Studio 2010 Tools for Office Runtime (x64)"
$newValuePath = "`"c:\Program Files\Common Files\Microsoft Shared\VSTO\10.0\Microsoft Visual Studio 2010 Tools for Office Runtime (x64)\install.exe`""
Set-ItemProperty -Path . -Name UninstallPath -Value $newValuePath -Verbose -ErrorAction SilentlyContinue

New-Item "C:\Windows\Temp\Unquoted-PathRemediation-VSTOR.log" -Force -Verbose -ErrorAction SilentlyContinue
Set-Content -Path "C:\Windows\Temp\Unquoted-PathRemediation-VSTOR.log" -Value "Unquoted path remediation for VSTOR was performed at HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Visual Studio 2010 Tools for Office Runtime (x64) for both the UninstallString and UninstallPath strings."