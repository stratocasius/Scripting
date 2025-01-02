$registryPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView"
$registryName = "InstallLocation"
$desiredValue = "C:\Program Files (x86)\Microsoft\EdgeWebView\Application\"

# Check if the registry key exists, and if not, create it
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# Set the InstallLocation value
Set-ItemProperty -Path $registryPath -Name $registryName -Value $desiredValue -Force

# Confirm the value was set correctly
$setLocation = Get-ItemProperty -Path $registryPath -Name $registryName
if ($setLocation.$registryName -eq $desiredValue) {
    Write-Output "InstallLocation set to: $desiredValue"
    exit 0
} else {
    Write-Output "Failed to set InstallLocation"
    exit 1
}
