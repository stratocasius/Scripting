### Enable WinRM - Remediation 
$ErrorActionPreference = "SilentlyContinue"

# Remediation Script
$service = Get-Service -Name WinRM -ErrorAction SilentlyContinue

if ($service) {
    try {
        Set-Service -Name WinRM -StartupType Automatic
        Start-Service -Name WinRM
        Enable-PSRemoting -Force
        Write-Output "WinRM service has been set to start automatically and started successfully."
    } catch {
        Write-Output "Failed to set WinRM service to start automatically and/or start the service."
    }
} else {
    Write-Output "WinRM service is not found."
}
