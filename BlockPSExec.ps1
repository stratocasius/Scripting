### Blocks PSExec.exe from connecting to remote PCs.
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\psexec.exe") -ne $true) {  New-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\psexec.exe" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\psexec.exe' -Name 'Debugger' -Value 'svchost.exe' -PropertyType String -Force -ea SilentlyContinue;

