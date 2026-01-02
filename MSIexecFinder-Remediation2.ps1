<#
Intune Remediation - Remediation Script
Kills any msiexec.exe processes and temporarily stops msiserver service.
Automatically confirms Stop-Process actions without interactive prompts.
Logs full transcript to C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\MsiexecKiller-Transcript.log
#>

# Suppress all confirmation prompts
$ConfirmPreference = 'None'

$LogRoot = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\Logs'
$TranscriptPath = Join-Path $LogRoot 'MSIkiller-Remediation.log'

if (-not (Test-Path $LogRoot)) { New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null }

try { Start-Transcript -Path $TranscriptPath -Append -ErrorAction SilentlyContinue } catch {}

Write-Output ("==== Remediation start: {0} ====" -f (Get-Date))

function Get-MsiexecProcessInfo {
    Get-CimInstance Win32_Process -Filter "Name='msiexec.exe'" -ErrorAction SilentlyContinue |
        Select-Object ProcessId, Name, CommandLine
}

function Stop-Msiexec {
    param(
        [int]$MaxAttempts = 3,
        [int]$SleepMsBetween = 1500
    )

    for ($i = 1; $i -le $MaxAttempts; $i++) {
        $procs = Get-MsiexecProcessInfo
        if (-not $procs) {
            Write-Output "No msiexec.exe processes found on attempt $i/$MaxAttempts."
            break
        }

        Write-Output ("Found {0} msiexec.exe process(es) on attempt {1}/{2}:" -f $procs.Count, $i, $MaxAttempts)
        foreach ($p in $procs) {
            Write-Output ("  PID {0} | Cmd: {1}" -f $p.ProcessId, ($p.CommandLine -replace '\s+', ' ').Trim())
            try {
                # Always confirm false to skip prompts
                Stop-Process -Id $p.ProcessId -ErrorAction Stop -Confirm:$false
                Write-Output ("Stopped msiexec PID {0} (normal)." -f $p.ProcessId)
            } catch {
                try {
                    Stop-Process -Id $p.ProcessId -Force -ErrorAction Stop -Confirm:$false
                    Write-Output ("Stopped msiexec PID {0} (forced)." -f $p.ProcessId)
                } catch {
                    Write-Output ("Failed to stop msiexec PID {0}: {1}" -f $p.ProcessId, $_.Exception.Message)
                }
            }
        }

        Start-Sleep -Milliseconds $SleepMsBetween
    }
}

# Stop msiserver to prevent respawn
try {
    $svc = Get-Service -Name msiserver -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -ne 'Stopped') {
        Write-Output "Stopping Windows Installer service (msiserver)..."
        Stop-Service -Name msiserver -Force -ErrorAction Continue -Confirm:$false
        try { Wait-Service -Name msiserver -Status Stopped -Timeout 30 } catch {}
    } else {
        Write-Output "Windows Installer service already stopped or missing."
    }
} catch {
    Write-Output "Unable to stop msiserver: $($_.Exception.Message)"
}

# Kill msiexec
Stop-Msiexec -MaxAttempts 3 -SleepMsBetween 1500

# Restart msiserver
try {
    Write-Output "Starting Windows Installer service (msiserver)..."
    Start-Service -Name msiserver -ErrorAction Continue
} catch {
    Write-Output "Unable to start msiserver: $($_.Exception.Message)"
}

Write-Output ("==== Remediation end: {0} ====" -f (Get-Date))

try { Stop-Transcript | Out-Null } catch {}
exit 0
