# Intune Detection Script - Startup Apps (User + System with Source Tags + Estimated Impact)
# Exit 0 = Compliant
# Exit 1 = Non-Compliant

$ErrorActionPreference = "SilentlyContinue"

$LogRoot = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogPath = Join-Path $LogRoot "StartupApps-$Stamp.log"

if (-not (Test-Path $LogRoot)) {
    New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "$time | $Message"
}

function Get-InteractiveUserName {
    try {
        $cs = Get-CimInstance Win32_ComputerSystem
        if (-not [string]::IsNullOrWhiteSpace($cs.UserName)) {
            return $cs.UserName.Split('\')[-1]
        }
    }
    catch { }

    return $env:USERNAME
}

function Get-InteractiveUserSid {
    try {
        $cs = Get-CimInstance Win32_ComputerSystem
        if ([string]::IsNullOrWhiteSpace($cs.UserName)) {
            return $null
        }

        $nt = New-Object System.Security.Principal.NTAccount($cs.UserName)
        return $nt.Translate([System.Security.Principal.SecurityIdentifier]).Value
    }
    catch {
        return $null
    }
}

function Get-UserProfilePath {
    param(
        [string]$Sid
    )

    if ([string]::IsNullOrWhiteSpace($Sid)) {
        return $null
    }

    try {
        $profile = Get-CimInstance Win32_UserProfile -ErrorAction SilentlyContinue |
            Where-Object { $_.SID -eq $Sid } |
            Select-Object -First 1

        if ($profile -and $profile.LocalPath) {
            return $profile.LocalPath
        }
    }
    catch { }

    return $null
}

function Get-ExeFromCommand {
    param(
        [string]$CommandText
    )

    if ([string]::IsNullOrWhiteSpace($CommandText)) {
        return $null
    }

    $cmd = $CommandText.Trim()

    if ($cmd -match '^\s*"(.*?)"') {
        $path = $matches[1]
        if ($path -match '(?i)\.exe$') {
            return [System.IO.Path]::GetFileName($path)
        }
    }

    if ($cmd -match '^\s*([A-Za-z]:\\.*?\.exe)\b') {
        return [System.IO.Path]::GetFileName($matches[1])
    }

    if ($cmd -match '(?i)\b([A-Za-z0-9._-]+\.exe)\b') {
        return $matches[1]
    }

    return $null
}

function Get-ExeFromShortcut {
    param(
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path $Path)) {
        return $null
    }

    try {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($Path)
        $target = $shortcut.TargetPath

        if (-not [string]::IsNullOrWhiteSpace($target) -and $target -match '(?i)\.exe$') {
            return [System.IO.Path]::GetFileName($target)
        }
    }
    catch { }

    return $null
}

function Get-RunEntries {
    param(
        [string]$Path,
        [string]$Tag
    )

    $items = @()

    try {
        if (Test-Path $Path) {
            $props = Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue
            if ($props) {
                $propNames = $props.PSObject.Properties |
                    Where-Object {
                        $_.MemberType -eq 'NoteProperty' -and
                        $_.Name -notin @('PSPath','PSParentPath','PSChildName','PSDrive','PSProvider')
                    }

                foreach ($p in $propNames) {
                    $exe = Get-ExeFromCommand -CommandText ([string]$p.Value)
                    if ($exe) {
                        $items += [PSCustomObject]@{
                            Exe     = $exe.ToLowerInvariant()
                            Source  = $Tag
                            Command = [string]$p.Value
                            Impact  = $null
                        }
                    }
                }
            }
        }
    }
    catch { }

    return @($items)
}

function Get-StartupFolderEntries {
    param(
        [string]$Folder,
        [string]$Tag
    )

    $items = @()

    try {
        if (Test-Path $Folder) {
            Get-ChildItem -Path $Folder -File -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.Extension -ieq ".exe") {
                    $items += [PSCustomObject]@{
                        Exe     = $_.Name.ToLowerInvariant()
                        Source  = $Tag
                        Command = $_.FullName
                        Impact  = $null
                    }
                }
                elseif ($_.Extension -ieq ".lnk") {
                    $exe = Get-ExeFromShortcut -Path $_.FullName
                    if ($exe) {
                        $items += [PSCustomObject]@{
                            Exe     = $exe.ToLowerInvariant()
                            Source  = $Tag
                            Command = $_.FullName
                            Impact  = $null
                        }
                    }
                }
            }
        }
    }
    catch { }

    return @($items)
}

function Get-EstimatedStartupImpact {
    param(
        [string]$Exe,
        [string]$Source,
        [string]$Command
    )

    $text = ($Exe + " " + $Source + " " + $Command).ToLowerInvariant()

    $highPatterns = @(
        'teams.exe',
        'msteams.exe',
        'outlook.exe',
        'chrome.exe',
        'msedge.exe',
        'firefox.exe',
        'zoom.exe',
        'slack.exe',
        'webex.exe',
        'citrix',
        'vmware',
        'logitech options',
        'ringcentral',
        'adobe',
        'acrobat'
    )

    $mediumPatterns = @(
        'onedrive.exe',
        'jabra',
        'poly',
        'plantronics',
        'hp',
        'dell',
        'lenovo',
        'intel',
        'realtek',
        'securityhealthsystray.exe',
        'dropbox.exe'
    )

    $lowPatterns = @(
        'explorer.exe',
        'ctfmon.exe',
        'rundll32.exe',
        'sihost.exe',
        'textinputhost.exe',
        'startmenuexperiencehost.exe'
    )

    foreach ($p in $highPatterns) {
        if ($text -like "*$p*") { return "High" }
    }

    foreach ($p in $mediumPatterns) {
        if ($text -like "*$p*") { return "Medium" }
    }

    foreach ($p in $lowPatterns) {
        if ($text -like "*$p*") { return "Low" }
    }

    if ($Source -eq "Startup") {
        return "Medium"
    }

    return "Low"
}

try {
    $user = Get-InteractiveUserName
    $sid = Get-InteractiveUserSid
    $profile = Get-UserProfilePath -Sid $sid

    Write-Log "=== Startup app enumeration started ==="
    Write-Log "User: $user"
    Write-Log "SID: $sid"
    Write-Log "Profile: $profile"

    $apps = @()

    # HKCU
    $apps += Get-RunEntries -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Tag "HKCU"

    # Startup folder
    if ($profile) {
        $startup = Join-Path $profile "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
        $apps += Get-StartupFolderEntries -Folder $startup -Tag "Startup"
    }

    # HKLM
    $apps += Get-RunEntries -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Tag "HKLM"

    if (-not $apps -or $apps.Count -eq 0) {
        Write-Log "No startup apps found."
        Write-Output "$user | Startup apps Total - 0 found | High Impact - 0 | Compliant - None found"
        exit 0
    }

    foreach ($app in $apps) {
        $app.Impact = Get-EstimatedStartupImpact -Exe $app.Exe -Source $app.Source -Command $app.Command
        Write-Log "Found: $($app.Exe) | Source=$($app.Source) | Impact=$($app.Impact) | Command=$($app.Command)"
    }

    $uniqueApps = $apps | Sort-Object Exe -Unique
    $totalCount = $uniqueApps.Count
    $highCount = @($uniqueApps | Where-Object { $_.Impact -eq "High" }).Count

    $output = $uniqueApps | ForEach-Object {
        "$($_.Exe) ($($_.Source), $($_.Impact))"
    }

    $status = if ($totalCount -ge 13) { "Non-Compliant" } else { "Compliant" }

    $summary = "$user | Startup apps Total - $totalCount found | High Impact - $highCount | $status - $($output -join ', ')"

    Write-Log "SUMMARY: $summary"
    Write-Output $summary

    if ($totalCount -ge 13) {
        exit 1
    }

    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Output "$user | Startup apps Total - 0 found | High Impact - 0 | Non-Compliant - Detection failed"
    exit 1
}