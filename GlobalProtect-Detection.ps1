# Check the registry for GlobalProtect
$requiredVersion = "6.1.4"
$apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
                          HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
        Where-Object { $_.DisplayName -eq "GlobalProtect" }

$versionMismatch = $true

if ($apps -ne $null) {
    foreach ($app in $apps) {
        # Output each found version
        Write-Output "GlobalProtect Installed: $($app.DisplayVersion)"
        if ($app.DisplayVersion -eq $requiredVersion) {
            $versionMismatch = $false
            break
        }
    }
} else {
    Write-Output "GlobalProtect Not found"
}

if ($versionMismatch) {
    # Signal that remediation is required
    exit 1
} else {
    # Correct version found, no action needed
    exit 0
}
