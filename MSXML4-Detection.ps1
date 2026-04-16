### MSXML Vulnerability Detection - 01/09/2026
# Detection - MSXML4 vulnerable DLLs (SysWOW64)
$msxml4  = "C:\Windows\SysWOW64\msxml4.dll"
$msxml4r = "C:\Windows\SysWOW64\msxml4r.dll"

if ((Test-Path $msxml4) -or (Test-Path $msxml4r)) {
    Write-Output "Non-compliant: MSXML4 DLL(s) present."
    exit 1
}

Write-Output "Compliant: MSXML4 DLL(s) not present."
exit 0