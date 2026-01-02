<#
.SYNOPSIS
  Detection script for Intune Proactive Remediation.
  Checks if the SecureProtocols registry value is set to 0x00002800 (TLS 1.2 + 1.3 Enabled) in HKCU. -JS
#>

# Attempt to read the current value of 'SecureProtocols'.
try {
    $currentValue = Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'SecureProtocols' -ErrorAction Stop
}
catch {
    # If the value doesn't exist, we consider it non-compliant.
    Write-Host "SecureProtocols registry value not found."
    Exit 1
}

if ($currentValue -eq 0x00002800) {
    Write-Host "Compliant: SecureProtocols is set to 0x00002800 (TLS 1.2 + 1.3 Enabled), Remediation not needed"
    Exit 0
}
else {
    Write-Host "Not Compliant: SecureProtocols is set to $($currentValue), expected 0x00002800. Remediation needed."
    Exit 1
}


#### Remediation

<#
.SYNOPSIS
  Remediation script for Intune Proactive Remediation.
  Sets the SecureProtocols registry value to 0x00002800 (TLS 1.2 + 1.3 Enabled) in HKCU if it is not already set. -JS
#>

try {
    # Force creation or update of the registry value
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' `
                     -Name 'SecureProtocols' `
                     -Value 0x00002800 `
                     -PropertyType DWord `
                     -Force | Out-Null

    Write-Host "Remediation successful: SecureProtocols set to 0x00002800."
    Exit 0
}
catch {
    Write-Host "Remediation failed: $($_.Exception.Message)"
    Exit 1
}