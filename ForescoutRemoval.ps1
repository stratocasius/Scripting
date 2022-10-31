$ForescoutProgID = "/x{7F0F33FD-6C76-4DB9-8CB9-15E8DDD20DF6}"
$ForescoutCmdline = "$ForescoutProgID /qn /l C:\Windows\Temp\Forescout-Removal.log"
Start-Process "msiexec.exe" -ArgumentList $ForescoutCmdline -wait -nonewwindow