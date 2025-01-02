# Define the registry path for TLS 1.3
$tls13RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3"

# Check if TLS 1.3 key exists
if (Test-Path $tls13RegistryPath) {
    # Disable TLS 1.3
    Set-ItemProperty -Path $tls13RegistryPath -Name "Enabled" -Value 0 -Type DWord -Verbose -WhatIf
    Write-Host "TLS 1.3 has been disabled."
} else {
    Write-Host "TLS 1.3 is not enabled on this system."
}
