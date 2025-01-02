# Get all msiexec.exe processes
$msiexecProcesses = Get-Process msiexec -ErrorAction SilentlyContinue

# Check if any msiexec.exe processes are found
if ($msiexecProcesses) {
    # If found, write output
    Write-Output "msiexec.exe processes found:"
    $msiexecProcesses | Format-Table Id, ProcessName, StartTime
    Stop-Process -Name "msiexec" -Force -ErrorAction SilentlyContinue
} else {
    # If not found, kill all msiexec.exe processes forcefully
    Write-Output "No msiexec.exe processes found. Attempting to kill any that may not be visible."
    Stop-Process -Name "msiexec" -Force -ErrorAction SilentlyContinue
}


