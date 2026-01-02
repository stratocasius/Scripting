# Check for "Netdocuments ndOffice Installer" in the specified registry paths
$uninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$targetDisplayName = "Netdocuments ndOffice Installer"
$ndFound = $false

foreach ($path in $uninstallPaths) {
    if (Test-Path $path) {
        try {
            $apps = Get-ItemProperty -Path (Join-Path $path "*") -ErrorAction Stop
            foreach ($app in $apps) {
                if ($null -ne $app.DisplayName -and $app.DisplayName -eq $targetDisplayName) {
                    Write-Host "Found target application in registry path: $path"
                    $ndFound = $true
                }
            }
        }
        catch {
            Write-Warning "Failed to read registry path: $path. Error: $_"
        }
    }
    else {
        Write-Warning "Registry path does not exist: $path"
    }
}

if ($ndFound) {
    $uninstallExe = "C:\jltools\AdobeAcrobatSuite\ndOfficeInstaller421.exe"
    $arguments   = "/uninstall /quiet /norestart /log C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndOfficeInstaller421EXE-UNINSTALL.log"

    if (Test-Path $uninstallExe) {
        Write-Host "Netdocuments ndOffice Installer detected. Running uninstall..."
        try {
            Set-Location -Path "C:\jltools\AdobeAcrobatSuite"
            Start-Process -FilePath $uninstallExe -ArgumentList $arguments -Wait -NoNewWindow
            Write-Host "Uninstall command executed."
        }
        catch {
            Write-Error "Failed to run uninstall command. Error: $_"
        }
    }
    else {
        Write-Error "Uninstall executable not found at path: $uninstallExe"
    }
}
else {
    Write-Host "Netdocuments ndOffice Installer not found in the specified registry locations."
}
