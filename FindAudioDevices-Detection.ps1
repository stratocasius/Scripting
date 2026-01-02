# Intune Detection Script - Check for functional audio device on Windows 11

# Get all sound devices with status OK and no config error
$soundDevices = Get-CimInstance Win32_SoundDevice | Where-Object {
    $_.Status -eq "OK" -and $_.ConfigManagerErrorCode -eq 0
}

# Determine result
if ($soundDevices.Count -gt 0) {
    Write-Output "Functional audio device(s) detected:"
    foreach ($device in $soundDevices) {
        Write-Output " - $($device.Name)"
    }
    exit 0  # Compliant
} else {
    Write-Output "No functional audio device found or devices are disabled."
    exit 1  # With Issues
}
