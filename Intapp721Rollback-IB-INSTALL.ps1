#############################################################################################################################
### Intapp Time 7.2.1 for Rollback 
$installLogFilePath = "C:\programdata\Microsoft\IntuneManagementExtension\Logs\IntappTime7.2.1Rollback-Transcript.log"
Start-Transcript $installLogFilePath

# Install Intapp Time 7.2.1 and installation logging to %PROGRAMDATA\Microsoft\IntuneManagementExtension\Logs\IntappTime7.2.1-INSTALL.log
Write-Output "Installing Intapp Time 7.2.1 with auto-update and deferred update channel settings. Safe Upgrade times are set during install for 7pm through 5am only."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"IntappTimeSetup721.msi`" /qn /norestart /l*v `"C:\programdata\Microsoft\IntuneManagementExtension\Logs\IntappTime7.2.1-INSTALL.log`"" -Wait -NoNewWindow
Write-Output "Intapp Time 7.2.1 installation complete. Logs created at C:\programdata\Microsoft\IntuneManagementExtension\Logs\IntappTime7.2.1-INSTALL.log."

### Install of Intapp Desktop Extension 7.2.1
### syntax from bat file
& cmd /c setup64.exe /verysilent /norestart /DEDestinationDirectory="C:\Program Files\Intapp\Desktop Extension" /TBAPIServiceURL="https://time.jacksonlewis.com:8080/APIService" /LaunchDE=false /CreateDEStartMenuShortcut=false /CreateTBStartMenuShortcut=false /Log=C:\programdata\Microsoft\IntuneManagementExtension\Logs\IntappDEx64Rollback-INSTALL.log

### hosts.cfg file Update
Rename-Item -Path "C:\Program Files (x86)\Intapp\Time\hosts.cfg" -NewName "hosts2.old" -Force -Verbose
Write-Output "Original hosts.cfg file renamed to hosts.old"
Copy-Item .\hosts.cfg -Destination "C:\Program Files (x86)\Intapp\Time" -Force -Verbose
Write-Output "Updated hosts.cfg placed at C:\Program Files x86\Intapp\Time\"

# ===== NEW: Restore Integration Builder from C:\jltools\Integration Builder-Rollback back to Program Files (x86) =====
try {
    if ($global:IB_WasPresent -eq $true) {
        $restoreSource = $global:IB_BackupFolder
        $destParent    = 'C:\Program Files (x86)\Intapp'
        $destFolder    = Join-Path $destParent 'Integration Builder'

        if (Test-Path -LiteralPath $restoreSource) {
            Write-Output "Restoring Integration Builder from '$restoreSource' to '$destFolder'."

            if (-not (Test-Path -LiteralPath $destParent)) {
                New-Item -Path $destParent -ItemType Directory -Force | Out-Null
                Write-Output "Created destination parent: $destParent"
            }
            
            # Copy back (no delete at destination), then ensure target is named 'Integration Builder'
            & robocopy "`"$restoreSource`"" "`"$destFolder`"" /E /R:1 /W:2 /NFL /NDL /NP | Out-Null
            $rc = $LASTEXITCODE
            if ($rc -ge 0 -and $rc -le 7) {
                Write-Output "Integration Builder restore completed successfully (robocopy exit code $rc)."
            } else {
                Write-Warning "Integration Builder restore may have failed (robocopy exit code $rc)."
            }
        } else {
            Write-Warning "Backup folder '$restoreSource' not found skipping restore."
        }
    } else {
        Write-Output "Integration Builder was not present initially; no restore needed."
    }
}
catch {
    Write-Warning "Error during Integration Builder restore: $($_.Exception.Message)."
    
# ===== END NEW: Restore block =====
}
Stop-Transcript