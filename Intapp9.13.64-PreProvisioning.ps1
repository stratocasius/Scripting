### Intapp Time 9.13.64 2505 for PreProvisioning,  Includes Desktop Extension 13.0.167 - 09/08/2025
### Removal of both Intapp Time and Desktop Extension if found as well as both Program Files (x86)/Program Files
### *** 9/8/25 - Edited /LaunchDE=true from /LaunchDE=false and included /NORESTART for initial IntappDE removal to not auto-restart during removal(line 69).

### Removal of previous installs of Intapp.
### Combined Uninstall Script for Intapp Time & Intapp Desktop Extension
# Define log files
$timeLog = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappTime-Removal.log"
$desktopExtLog = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappDesktopExtension-Uninstall.log"

# Start logging for Intapp Time
Start-Transcript -Path $timeLog

# Attempt to stop IntappTime if running
try {
    Stop-Process -Name "IntappTime" -Force -Verbose -ErrorAction SilentlyContinue
    Write-Output "Stopped IntappTime process if it was running."
} catch {
    Write-Warning "IntappTime process not found or could not be stopped."
}

# Track uninstalled apps
$uninstalledApps = @()

# Define uninstall registry paths
$uninstallPaths = @(
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
        Start-Process -FilePath $uninstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait -NoNewWindow
        Write-Output "Desktop Extension uninstall executed."
    } else {
        Write-Warning "Uninstaller not found at: $uninstaller"
    }
} catch {
    Write-Error "Error during Desktop Extension uninstall: $_"
}

# Remove folder locations
$foldersToRemove = @(
    "C:\Program Files\Intapp\Desktop Extension",
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

### Begin Intapp Time 9.13.64 Installers.

# Track script start time
$global:ScriptStartTime = Get-Date

# Start transcript
$installLogFilePath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappTime9.13.64PreProvisioning-Transcript.log"
Start-Transcript $installLogFilePath

# Check for .NET 4.8
$netfxRegPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
$netfxVersion = Get-ItemProperty -Path $netfxRegPath -Name Release -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Release

# .NET 4.8 release key = 528040 or higher
if ($netfxVersion -lt 528040) {
    Write-Output ".NET Framework 4.8 not detected. Installing now..."

    # Get current script directory
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $dotNetInstaller = Join-Path $scriptDirectory "ndp48-x86-x64-allos-enu.exe"

    if (Test-Path $dotNetInstaller) {
        Start-Process -FilePath $dotNetInstaller -ArgumentList "/quiet", "/norestart" -Wait -NoNewWindow
        Write-Output "Intapp Time pre-req check for .NET Framework 4.8 installation complete. A reboot maybe required."
        } else {
        Write-Error ".NET 4.8 installer not found at $dotNetInstaller"
               
    }
} else {
    Write-Output "Intapp Time pre-req check for .NET Framework 4.8 or newer is already installed."
}

# Proceed with Intapp Time install - *** CHECK Safe Upgrade time settings for new version 12.0
Write-Output "Installing Intapp Time 9.13.64."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"IntappTimeSetup.msi`" /qn DATAFOLDERUI=%appdata%\Intapp\Time\Data /norestart /l*v `"C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappTime9.13.64-INSTALL.log`"" -Wait -NoNewWindow
Write-Output "Intapp Time 9.13.64 installation complete. Logs created at C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappTime9.13.64-INSTALL.log on $(Get-Date)."

# Install Intapp Desktop Extension 13.0.167.177
& cmd /c "time.desktop.extension.installer.64.13.0.167.exe" /verysilent /norestart /DEDestinationDirectory="C:\Program Files\Intapp\Desktop Extension" /LaunchDE=true /CreateDEStartMenuShortcut=false /CreateTBStartMenuShortcut=false /Log=C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappDEx64-130PreProvisioning-INSTALL.log

# Replace hosts.cfg file
# Rename-Item -Path "C:\Program Files (x86)\Intapp\Time\hosts.cfg" -NewName "hosts.old" -Force -Verbose
# Write-Output "Original hosts.cfg file renamed to hosts.old"
# Copy-Item .\hosts.cfg -Destination "C:\Program Files (x86)\Intapp\Time" -Force -Verbose
# Write-Output "Updated hosts.cfg placed at C:\Program Files (x86)\Intapp\Time\ on $(Get-Date)"

# Calculate script duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("Intapp Time 9.13.64 and Desktop Extension 13.167.177 Install total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)

Stop-Transcript