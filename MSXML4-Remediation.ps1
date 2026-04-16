# Remediation - Unregister + delete MSXML4 vulnerable DLLs (SysWOW64)
# Runs in SYSTEM context (no LocalAppData output)

$msxml4  = "C:\Windows\SysWOW64\msxml4.dll"
$msxml4r = "C:\Windows\SysWOW64\msxml4r.dll"

$logPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\MSXML4-Remediation.log"

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$ts - $Message"
    Write-Output $line
    try { Add-Content -Path $logPath -Value $line -ErrorAction SilentlyContinue } catch {}
}

function Unregister-And-Delete {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        Write-Log "Not found (no action): $FilePath"
        return $true
    }

    # Unregister
    try {
        Write-Log "Unregistering: $FilePath"
        $p = Start-Process -FilePath "regsvr32.exe" -ArgumentList "/u /s `"$FilePath`"" -Wait -PassThru
        Write-Log "regsvr32 exit code: $($p.ExitCode) for $FilePath"
    }
    catch {
        Write-Log "ERROR: Failed to unregister $FilePath - $($_.Exception.Message)"
        return $false
    }

    # Delete
    try {
        Write-Log "Deleting: $FilePath"
        Remove-Item -Path $FilePath -Force -ErrorAction Stop
        Write-Log "Deleted: $FilePath"
        return $true
    }
    catch {
        Write-Log "ERROR: Failed to delete $FilePath - $($_.Exception.Message)"
        return $false
    }
}

Write-Log "Starting MSXML4 remediation..."

$ok1 = Unregister-And-Delete -FilePath $msxml4
$ok2 = Unregister-And-Delete -FilePath $msxml4r

# Final verification
if ((Test-Path $msxml4) -or (Test-Path $msxml4r) -or (-not $ok1) -or (-not $ok2)) {
    Write-Log "Remediation failed or incomplete: one or more DLLs still present and/or errors occurred."
    Write-Output "Remediation failed or incomplete: one or more DLLs still present and/or errors occurred."
    exit 1
}

Write-Log "Remediation successful: MSXML4 DLLs not present."
Write-Output "Remediation successful: MSXML4 DLLs not present."
exit 0
