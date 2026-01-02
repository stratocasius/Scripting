<#
Intune Remediation - Msiexec killer (no prompts)
- Transcript: C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\MsiexecKiller-Transcript.log
- Kills any running msiexec.exe without confirmation prompts
#>

$ErrorActionPreference = 'SilentlyContinue'
$ConfirmPreference = 'None'  # belt-and-suspenders, but taskkill avoids ShouldProcess entirely

$LogRoot = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\Logs'
$TranscriptPath = Join-Path $LogRoot 'MsiexecKiller-Transcript.log'
if (-not (Test-Path $LogRoot)) { New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null }

try { Start-Transcript -Path $TranscriptPath -Append -ErrorAction SilentlyContinue } catch {}

Write-Output ("==== Remediation start: {0} ====" -f (Get-Date))

# Stop Windows Installer service to reduce immediate respawn
try {
    $svc = Get-Service -Name msiserver -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -ne 'Stopped') {
        Write-Output "Stopping Windows Installer service (msiserver)..."
        Stop-Service -Name msiserver -Force -ErrorAction Continue
        try { Wait-Service -Name msiserver -Status Stopped -Timeout 30 } catch {}
    } else {
        Write-Output "msiserver already stopped or not present."
    }
} catch { Write-Output "Unable to stop msiserver: $($_.Exception.Message)" }

# Kill any running msiexec.exe (no confirmation prompts)
Write-Output "Killing msiexec.exe (pass 1)..."
cmd.exe /c "taskkill /F /IM msiexec.exe /T" | Out-Null
Start-Sleep -Seconds 2

# Check if any remain; try once more
try {
    $left = Get-Process -Name msiexec -ErrorAction SilentlyContinue
    if ($left) {
        Write-Output "Killing msiexec.exe (pass 2)..."
        cmd.exe /c "taskkill /F /IM msiexec.exe /T" | Out-Null
    } else {
        Write-Output "No msiexec.exe processes remain after pass 1."
    }
} catch {}

# Start Windows Installer again
try {
    Write-Output "Starting Windows Installer service (msiserver)..."
    Start-Service -Name msiserver -ErrorAction Continue
} catch { Write-Output "Unable to start msiserver: $($_.Exception.Message)" }

Write-Output ("==== Remediation end: {0} ====" -f (Get-Date))
try { Stop-Transcript | Out-Null } catch {}
exit 0
