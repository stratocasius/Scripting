# Intune Remediation Script
# Exit 1 = msiexec.exe was found and terminated
# Exit 0 = msiexec.exe was not running

$msiexecProcesses = Get-Process -Name msiexec -ErrorAction SilentlyContinue

if ($null -ne $msiexecProcesses) {

    Write-Output "msiexec.exe process(es) found. Terminating..."

    $msiexecProcesses | ForEach-Object {
        Write-Output "Killing msiexec.exe | PID: $($_.Id) | StartTime: $($_.StartTime)"
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction Stop
        }
        catch {
            Write-Output "ERROR: Failed to terminate msiexec.exe PID $($_.Id): $($_.Exception.Message)"
        }
    }

    # Verify termination
    Start-Sleep -Seconds 2
    if (Get-Process -Name msiexec -ErrorAction SilentlyContinue) {
        Write-Output "WARNING: One or more msiexec.exe processes are still running."
        exit 1
    }

    Write-Output "msiexec.exe successfully terminated."
    exit 1
}
else {
    Write-Output "No msiexec.exe processes found."
    exit 0
}