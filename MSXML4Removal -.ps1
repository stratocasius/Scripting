### MSXML4 Removal - 
### Check if msxml4.dll exists
if (Test-Path "C:\Windows\SysWOW64\msxml4.dll") {
    # Unregister msxml4.dll
    regsvr32.exe /u /s "C:\Windows\SysWOW64\msxml4.dll"
    
    # Delete msxml4.dll
    Remove-Item "C:\Windows\SysWOW64\msxml4.dll" -Force -ErrorAction SilentlyContinue
    Add-Content -Path "C:\Windows\Temp\MSxml4-Removal" -Value "MSXML4 Removal App removed C:\Windows\SysWOW64\msxml4.dll on "$Get-Date""
}
# Check if msxml4r.dll exists
if (Test-Path "C:\Windows\SysWOW64\msxml4r.dll") {
    # Unregister msxml4r.dll
    regsvr32.exe /u /s "C:\Windows\SysWOW64\msxml4r.dll"
    
    # Delete msxml4r.dll
    Remove-Item "C:\Windows\SysWOW64\msxml4r.dll" -Force -ErrorAction SilentlyContinue
    Add-Content -Path "C:\Windows\Temp\MSxml4r-Removal.log" -Value "MSXML4 Removal App removed C:\Windows\SysWOW64\msxml4r.dll on "$Get-Date""
}