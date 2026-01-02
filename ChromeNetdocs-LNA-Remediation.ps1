# Remediation: Ensure Chrome LocalNetworkAccessAllowedForUrls contains "1"="https://vault.netvoyage.com/"
# Logs transcript to: C:\programdata\microsoft\intunemanagementextension\logs\netdocs.log
# Run as SYSTEM (HKLM writes)

$ErrorActionPreference = 'Stop'

$regKey       = 'HKLM:\SOFTWARE\Policies\Google\Chrome\LocalNetworkAccessAllowedForUrls'
$regValueName = '1'
$expected     = 'https://vault.netvoyage.com'

$logDir  = 'C:\programdata\microsoft\intunemanagementextension\logs'
$logFile = Join-Path $logDir 'ChromeNetdocs-LNA-Remediation.log'

# Ensure log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Start transcript
try { Start-Transcript -Path $logFile -Append | Out-Null } catch {}

try {
    Write-Output "Starting remediation for Chrome LocalNetworkAccessAllowedForUrls."

    # Ensure the registry key exists
    if (-not (Test-Path $regKey)) {
        New-Item -Path $regKey -Force | Out-Null
        Write-Output "Created registry key: $regKey"
    } else {
        Write-Output "Registry key exists: $regKey"
    }

    # Read current value (if any)
    $current = $null
    try {
        $prop = Get-ItemProperty -Path $regKey -Name $regValueName -ErrorAction Stop
        $current = $prop.$regValueName
    } catch {
        Write-Output "Value '$regValueName' not present; will create."
    }

    if ($null -eq $current) {
        New-ItemProperty -Path $regKey -Name $regValueName -Value $expected -PropertyType String -Force | Out-Null
        Write-Output "Created value '$regValueName' = '$expected'."
    } elseif ($current -ne $expected) {
        Set-ItemProperty -Path $regKey -Name $regValueName -Value $expected
        Write-Output "Updated value '$regValueName' from '$current' to '$expected'."
    } else {
        Write-Output "Value '$regValueName' already set correctly."
    }

    # Verify and exit
    $verify = (Get-ItemProperty -Path $regKey -Name $regValueName -ErrorAction Stop).$regValueName
    if ($verify -eq $expected) {
        Write-Output "Verification succeeded. Remediation complete."
        try { Stop-Transcript | Out-Null } catch {}
        exit 0
    } else {
        Write-Output "Verification failed. Current='$verify' Expected='$expected'."
        try { Stop-Transcript | Out-Null } catch {}
        exit 1
    }
}
catch {
    Write-Output "Remediation error: $($_.Exception.Message)"
    try { Stop-Transcript | Out-Null } catch {}
    exit 1
}
