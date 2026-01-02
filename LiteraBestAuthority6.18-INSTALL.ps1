### Litera BestAuthority 6.18.1.2 for Pre-provisioning - 11/06/2025

### Establish Litera Best Authority removal transcript
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\LiteraBestAuthorityRemoval-Transcript.log"
### Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\LiteraBestAuthorityRemoval-Transcript.log"

### Adding LevitJames.Register.exe to AV process exclusion
Write-Output "Adding LevitJames.Register.exe to antivirus exclusion list..."
Add-MpPreference -ExclusionProcess LevitJames.Register.exe
Write-Output "LevitJames.Register.exe added to antivirus exclusion list."

# --- PREPEND: Remove any existing "Litera Best Authority (64-bit)" before install ---
try {
    $targets = @()
    $roots = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )

    foreach ($root in $roots) {
        if (Test-Path $root) {
            $targets += Get-ChildItem $root -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    $p = Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue
                    if ($p.DisplayName -eq 'Litera Best Authority (64-bit)' -and ($p.UninstallString -or $p.QuietUninstallString)) {
                        [pscustomobject]@{
                            KeyPath              = $_.PSPath
                            DisplayName          = $p.DisplayName
                            DisplayVersion       = $p.DisplayVersion
                            QuietUninstallString = $p.QuietUninstallString
                            UninstallString      = $p.UninstallString
                        }
                    }
                } catch { $null }
            }
        }
    }

    if ($targets -and $targets.Count -gt 0) {
        Write-Output ("Found {0} instance(s) of 'Litera Best Authority (64-bit)' to uninstall..." -f $targets.Count)
        foreach ($t in $targets) {
            $raw = if ($t.QuietUninstallString) { $t.QuietUninstallString } else { $t.UninstallString }
            $cmd = $raw

            if ($raw -match '(?i)msiexec\.exe') {
                # Normalize MSI to silent uninstall
                $cmd = $raw
                if ($cmd -match '(?i)\s/I\b') { $cmd = $cmd -replace '(?i)\s/I\b', ' /X' }
                if ($cmd -notmatch '(?i)\s/X\b') { $cmd = $cmd -replace '(?i)msiexec\.exe', 'msiexec.exe /X' }
                if ($cmd -notmatch '(?i)\s/qn\b') { $cmd += ' /qn' }
                if ($cmd -notmatch '(?i)\s/norestart\b') { $cmd += ' /norestart' }
            }

            Write-Output "Uninstalling: $($t.DisplayName) $($t.DisplayVersion)"
            Write-Output "Using: $cmd"
            try {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -Wait -NoNewWindow
                Start-Sleep -Seconds 2
            } catch {
                Write-Output "Uninstall attempt failed: $($_.Exception.Message)"
            }
        }
    } else {
        Write-Output "No existing 'Litera Best Authority (64-bit)' installations found."
    }
}
catch {
    Write-Output "Pre-uninstall step encountered an error: $($_.Exception.Message)"
}
Stop-Transcript

### Establish Litera Best Authority 6.18.1 install transcript
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\LiteraBestAuthority6.18.1-Transcript.log"
### Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\LiteraBestAuthority6.18.1-Transcript.log"

### Install log path
Write-Output "Installing BestAuthority with logging at %PROGRAMDATA%\Microsoft\IntuneManagementExtension\Logs\BestAuthority6.18.1-MSI-INSTALL.log"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"BestAuthority_6.18.1_x64.msi`" /qn LICENSEKEY=BA-300Iw2l-ST0-E-Q6F48 ACCEPT_EULA_AND_TPLA=1 ISINSTALLLITERATAB=1 /norestart /l*v `"C:\programdata\microsoft\IntuneManagementExtension\Logs\LiteraBestAuthority6.18.1-INSTALL.log" -Wait -NoNewWindow
Write-Output "BestAuthority 6.18.1 installation and configuration complete on $(Get-Date)."

### Remove AV exclusion 
### Log message before removing LevitJames.Register.exe to AV process exclusion
Write-Output "Removing LevitJames.Register.exe to antivirus exclusion list..."
Remove-MpPreference -ExclusionProcess LevitJames.Register.exe 
Write-Output "LevitJames.Register.exe removed from antivirus exclusion list."

# End transcript
Stop-Transcript
