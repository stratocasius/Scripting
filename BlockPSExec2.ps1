### PSexec.exe blocking script(per Security) - 10/7/2022
New-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\psexec.exe" -force -ea SilentlyContinue -Verbose
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\psexec.exe' -Name 'Debugger' -Value 'svchost.exe' -PropertyType String -Force -ea SilentlyContinue -Verbose