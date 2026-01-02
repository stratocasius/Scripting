### Removal of previous installs of Intapp.
### Combined Uninstall Script for Intapp Time & Intapp Desktop Extension
# Define log files
$timeLog = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappTimeRollback-Removal.log"
$desktopExtLog = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappDesktopExtensionRollback-Uninstall.log"
# Track script start time
$global:ScriptStartTime = Get-Date

# Start logging for Intapp Time Update with IB handling.
Start-Transcript -Path $timeLog
# ===================== NEW: Integration Builder folder detection & copy =====================
try {
    $global:IntegrationBuilderWasPresent = $false
    $srcDir  = 'C:\Program Files (x86)\Intapp\Integration Builder'
    $dstRoot = 'C:\jltools'
    $dstDir  = Join-Path $dstRoot 'Integration Builder'

    if (Test-Path -LiteralPath $srcDir) {
        $global:IntegrationBuilderWasPresent = $true
        Write-Output "Integration Builder folder detected at '$srcDir'. Preparing to copy to '$dstDir'."

        if (-not (Test-Path -LiteralPath $dstRoot)) {
            New-Item -Path $dstRoot -ItemType Directory -Force | Out-Null
            Write-Output "Created destination root: $dstRoot"
        }

        # Use robocopy for reliable recursive copy (no deletions at destination)
        $rcArgs = @("`"$srcDir`"", "`"$dstDir`"", '/E', '/R:1', '/W:2', '/NFL', '/NDL', '/NP')
        Write-Output "Copying Integration Builder contents to $dstDir ..."
        & robocopy @rcArgs | Out-Null
        $rc = $LASTEXITCODE

        if ($rc -ge 0 -and $rc -le 7) {
            Write-Output "Copy completed successfully (robocopy exit code $rc)."
        } else {
            Write-Warning "Copy may have failed (robocopy exit code $rc). Please review."
        }
    } else {
        Write-Output "Integration Builder folder not found at '$srcDir'. Continuing without copy."
    }
}
catch {
    Write-Warning "Integration Builder copy step encountered an error: $($_.Exception.Message)"
}
# =================== END: Integration Builder folder detection & copy ===================

# Attempt to stop IntappTime if running
try {
    Stop-Process -Name "IntappTime" -Force -ErrorAction SilentlyContinue
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
################################################################################################################################
# Start transcript
$installLogFilePath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappTime7.2.1.300Rollback-Transcript.log"
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

# Proceed with Intapp Time 7.2.1 Install
Write-Output "Installing Intapp Time 7.2.1.300."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"IntappTimeSetup.msi`" /qn /norestart /l*v `"C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappTime721Rollback-INSTALL.log`"" -Wait -NoNewWindow
Write-Output "Intapp Time 7.2.1.300 installation complete. Logs created at C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappTime721Rollback-INSTALL.log on $(Get-Date)."

# Install Intapp Desktop Extension 7.2.1.300
& cmd /c "setup64.exe" /verysilent /norestart /DEDestinationDirectory="C:\Program Files\Intapp\Desktop Extension" /LaunchDE=true /CreateDEStartMenuShortcut=false /CreateTBStartMenuShortcut=false /Log=C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntappDE721Rollback-INSTALL.log

# Replace hosts.cfg file
Rename-Item -Path "C:\Program Files (x86)\Intapp\Time\hosts.cfg" -NewName "hosts.old" -Force -Verbose
Write-Output "Original hosts.cfg file renamed to hosts.old"
Copy-Item .\hosts.cfg -Destination "C:\Program Files (x86)\Intapp\Time" -Force -Verbose
Write-Output "Updated hosts.cfg placed at C:\Program Files (x86)\Intapp\Time\ on $(Get-Date)"

# ===================== NEW: Integration Builder folder restore =====================
try {
    if ($global:IntegrationBuilderWasPresent -eq $true) {
        $srcDir = 'C:\jltools\Integration Builder'
        $dstDir = 'C:\Program Files (x86)\Intapp\Integration Builder'

        if (Test-Path -LiteralPath $srcDir) {
            Write-Output "Integration Builder was previously backed up. Restoring from '$srcDir' to '$dstDir'."

            if (-not (Test-Path (Split-Path $dstDir))) {
                New-Item -Path (Split-Path $dstDir) -ItemType Directory -Force | Out-Null
                Write-Output "Created parent folder: $(Split-Path $dstDir)"
            }

            $rcArgs = @("`"$srcDir`"", "`"$dstDir`"", '/E', '/R:1', '/W:2', '/NFL', '/NDL', '/NP')
            & robocopy @rcArgs | Out-Null
            $rc = $LASTEXITCODE

            if ($rc -ge 0 -and $rc -le 7) {
                Write-Output "Integration Builder restore completed successfully."
            } else {
                Write-Warning "Integration Builder restore may have failed (robocopy exit code $rc)."
            }
        } else {
            Write-Warning "Backup folder '$srcDir' not found. Skipping restore."
        }
    } else {
        Write-Output "Integration Builder was not detected at start, no restore needed."
    }
}
catch {
    Write-Warning "Integration Builder restore encountered an error: $($_.Exception.Message)"
}
# =================== END: Integration Builder folder restore ===================
# Calculate script duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("Intapp Time 7.2.1 and Desktop Extension 7.2.1 Install total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)

Stop-Transcript