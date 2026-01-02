<#
Intune Remediation - Remediation
- Logs full transcript to C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\MsiexecKiller-Transcript.log
- Attempts to stop all msiexec.exe processes (gracefully then force)
- Temporarily stops Windows Installer service (msiserver) to prevent immediate respawn
- Starts Windows Installer service again at the end (keeps default Manual startup type)
#>

$LogRoot = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\Logs'
$TranscriptPath = Join-Path $LogRoot 'MsiexecKiller-Transcript.log'

# Ensure log directory exists
if (-not (Test-Path $LogRoot)) { New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null }

# Start transcript
try {
    Start-Transcript -Path $TranscriptPath -Append -ErrorAction SilentlyContinue
} catch {
    # Fall back: write a simple header to a log file if transcript fails for any reason
    "[{0}] Failed to start transcript: {1}" -f (Get-Date), $_.Exception.Message | Out-File -FilePath $TranscriptPath -Append -Encoding UTF8
}

Write-Output ("==== Remediation start: {0} ====" -f (Get-Date))

function Get-MsiexecProcessInfo {
    try {
        # Use CIM to capture CommandLine details
        Get-CimInstance Win32_Process -Filter "Name='msiexec.exe'" -ErrorAction SilentlyContinue |
            Select-Object ProcessId, Name, CommandLine
    } catch {
        @()
    }
}

function Stop-Msiexec {
    param(
        [int]$MaxAttempts = 2,
        [int]$SleepMsBetween = 1000
    )

    for ($i = 1; $i -le $MaxAttempts; $i++) {
        $procs = Get-MsiexecProcessInfo
        if (-not $procs -or $procs.Count -eq 0) {
            Write-Output "No msiexec.exe processes found on attempt $i/$MaxAttempts."
            break
        }

        Write-Output ("Found {0} msiexec.exe process(es) on attempt {1}/{2}:" -f $procs.Count, $i, $MaxAttempts)
        $procs | ForEach-Object {
            Write-Output (" - PID {0} | Cmd: {1}" -f $_.ProcessId, ($_.CommandLine -replace '\s+', ' ').Trim())
        }

        foreach ($p in $procs) {
            try {
                # Try a normal stop first; if that fails, force it
                Stop-Process -Id $p.ProcessId -ErrorAction Stop
                Write-Output ("Stopped msiexec PID {0} (normal)." -f $p.ProcessId)
            } catch {
                try {
                    Stop-Process -Id $p.ProcessId -Force -ErrorAction Stop
                    Write-Output ("Stopped msiexec PID {0} (forced)." -f $p.ProcessId)
                } catch {
                    Write-Output ("Failed to stop msiexec PID {0}: {1}" -f $p.ProcessId, $_.Exception.Message)
                }
            }
        }

        Start-Sleep -Milliseconds $SleepMsBetween
    }
}

# Briefly stop Windows Installer (msiserver) to reduce immediate respawn
try {
    $svc = Get-Service -Name msiserver -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -ne 'Stopped') {
        Write-Output "Stopping Windows Installer service (msiserver)..."
        Stop-Service -Name msiserver -Force -ErrorAction Continue
        try { Wait-Service -Name msiserver -Status Stopped -Timeout 30 } catch {}
    } else {
        Write-Output "Windows Installer service (msiserver) already stopped or not present."
    }
} catch {
    Write-Output "Unable to stop msiserver: $($_.Exception.Message)"
}

# Kill any running msiexec.exe
Stop-Msiexec -MaxAttempts 3 -SleepMsBetween 1500

# Optional: start Windows Installer again (default startup type is Manual/Demand)
try {
    Write-Output "Starting Windows Installer service (msiserver)..."
    Start-Service -Name msiserver -ErrorAction Continue
} catch {
    Write-Output "Unable to start msiserver: $($_.Exception.Message)"
}

Write-Output ("==== Remediation end: {0} ====" -f (Get-Date))

# End transcript
try {
    Stop-Transcript | Out-Null
} catch {}
exit 0