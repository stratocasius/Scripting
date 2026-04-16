# Find all running msiexec.exe processes
$msiProcesses = Get-CimInstance Win32_Process -Filter "Name='msiexec.exe'" |
    Where-Object { $_.ExecutablePath -ieq "C:\Windows\SysWOW64\msiexec.exe" }

if ($msiProcesses) {
    foreach ($proc in $msiProcesses) {
        Write-Host "Stopping msiexec.exe (PID: $($proc.ProcessId)) running from SysWOW64"
        Stop-Process -Id $proc.ProcessId -Force
    }
} else {
    Write-Host "No SysWOW64 msiexec.exe processes found."
}
