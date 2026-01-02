### Combined Uninstall Script for Intapp Time & Intapp Desktop Extension

# Define log files
$timeLog = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappTime9.13.64-Removal.log"
$desktopExtLog = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappDesktopExtension-Uninstall.log"

# Start logging for Intapp Time
Start-Transcript -Path $timeLog

# Track uninstalled apps
$uninstalledApps = @()

# Define uninstall registry paths
$uninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Uninstall Intapp Time
foreach ($path in $uninstallPaths) {
    Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
        $appKey = $_.PSPath
        $displayName = (Get-ItemProperty -Path $appKey -Name DisplayName -ErrorAction SilentlyContinue).DisplayName
        $displayVersion = (Get-ItemProperty -Path $appKey -Name DisplayVersion -ErrorAction SilentlyContinue).DisplayVersion
        $uninstallString = (Get-ItemProperty -Path $appKey -Name UninstallString -ErrorAction SilentlyContinue).UninstallString

        if ($displayName -and $uninstallString -and $displayName -match "Intapp Time") {
            try {
                $cmd = $uninstallString
                if ($cmd -match "MsiExec\.exe\s+/I") {
                    $cmd = $cmd -replace "/I", "/X"
                }
                if ($cmd -notmatch "/qn") {
                    $cmd += " /qn"
                }

                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -Wait -NoNewWindow
                Write-Output "Successfully uninstalled $displayName $displayVersion"
                $uninstalledApps += "$displayName $displayVersion"
            }
            catch {
                Write-Error "Failed to uninstall $displayName : $_"
            }
        }
    }
}

Stop-Transcript

# Start logging for Desktop Extension
Start-Transcript -Path $desktopExtLog -Append

# Uninstall Desktop Extension
$uninstaller = "C:\Program Files\Intapp\Desktop Extension\unins000.exe"
try {
    if (Test-Path $uninstaller) {
        Write-Output "Found Desktop Extension uninstaller. Running silent uninstall..."
        Start-Process -FilePath $uninstaller -ArgumentList "/SILENT /NORESTART" -Wait -NoNewWindow
        Write-Output "Desktop Extension uninstall executed."
    } else {
        Write-Warning "Uninstaller not found at: $uninstaller"
    }
} catch {
    Write-Error "Error during Desktop Extension uninstall: $_"
}

# Remove folder locations
$foldersToRemove = @(
    "C:\Program Files\Intapp",
    "C:\Program Files (x86)\Intapp"
)

foreach ($folder in $foldersToRemove) {
    try {
        if (Test-Path $folder) {
            Remove-Item -Path $folder -Recurse -Force -ErrorAction Stop
            Write-Output "Successfully removed folder: $folder"
        } else {
            Write-Output "Folder not found: $folder"
        }
    } catch {
        Write-Error "Failed to remove folder $folder : $_"
    }
}

# Log removed apps
if ($uninstalledApps.Count -gt 0) {
    Write-Output "Apps uninstalled: $($uninstalledApps -join ", ")"
}

Stop-Transcript