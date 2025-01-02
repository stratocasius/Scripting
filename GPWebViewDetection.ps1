$registryPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView"
$registryName = "InstallLocation"

# Check if the registry key exists
if (Test-Path $registryPath) {
    # Get the InstallLocation value
    $installLocation = Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue

    if ($installLocation) {
        # Write out the current value and exit with code 0
        Write-Output "No Remediation Needed: $registryPath $registryName Value: $($installLocation.$registryName)"
        exit 0
    }
}

# If not found, exit with code 1
Write-Output "InstallLocation not found. Remediation Needed"
exit 1
