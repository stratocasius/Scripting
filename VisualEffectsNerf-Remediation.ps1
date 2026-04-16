# Remediation: Windows 11 Visual Effects Remediation - 02/19/2026
# - Disable desktop icon shadows -     https://community.spiceworks.com/t/adjust-for-best-performance-in-visual-effects-and-also-show-shadows-under-window/935063
# - Show thumbnails instead of icons - https://www.ntlite.com/community/index.php?threads/feature-request-additional-file-explorer-defaults-customizations.2640/
# - Smooth edges of screen fonts -     https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.systeminformation.fontsmoothingtype?view=windowsdesktop-9.0
# - Show window contents while dragging - https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/remote-desktop-services-vdi-optimize-configuration
# Works in SYSTEM context by writing into the interactive user's hive under HKEY_USERS\<SID>
######################
# Establish transcript
$logFilepath = "$($env:PROGRAMDATA)\Microsoft\IntuneManagementExtension\Logs\VisualEffects-Remediation-Transcript.log"
### Start logging
Start-Transcript -Append $logFilepath

$ErrorActionPreference = "Stop"

function Get-InteractiveUserSid {
    try {
        $explorer = Get-Process explorer -ErrorAction Stop | Select-Object -First 1
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$($explorer.Id)" -ErrorAction Stop
        $owner = $proc | Invoke-CimMethod -MethodName GetOwnerSid -ErrorAction Stop
        return $owner.Sid
    } catch {
        return $null
    }
}

function Set-UserRegDword {
    param(
        [Parameter(Mandatory=$true)][string]$Sid,
        [Parameter(Mandatory=$true)][string]$SubKey,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][int]$Value
    )
    $path = "Registry::HKEY_USERS\$Sid\$SubKey"
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    New-ItemProperty -Path $path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
}

# Resolve target user SID
$Sid = Get-InteractiveUserSid
if (-not $Sid) {
    Write-Output "No interactive user detected (explorer.exe not found). Exiting."
    exit 0
}

Write-Output "Target interactive user SID: $Sid"

# 1) Disable Desktop Icon Shadows
# HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ListviewShadow = 0
Set-UserRegDword -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0
Write-Output "Set ListviewShadow=0 (disable desktop icon shadows)."

# 2) Show thumbnails instead of icons
# HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\IconsOnly = 0
# 0 = show thumbnails, 1 = show icons only
Set-UserRegDword -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value 0
Write-Output "Set IconsOnly=0 (show thumbnails instead of icons)."

# 3) Smooth edges of screen fonts (font smoothing)
# HKCU\Control Panel\Desktop\FontSmoothing = "2" (string)
# HKCU\Control Panel\Desktop\FontSmoothingType = 2 (DWORD)  (ClearType)
# HKCU\Control Panel\Desktop\FontSmoothingGamma = 1500 (DWORD) (common default)
$desktopPath = "Registry::HKEY_USERS\$Sid\Control Panel\Desktop"
if (-not (Test-Path $desktopPath)) { New-Item -Path $desktopPath -Force | Out-Null }

New-ItemProperty -Path $desktopPath -Name "FontSmoothing" -PropertyType String -Value "2" -Force | Out-Null
New-ItemProperty -Path $desktopPath -Name "FontSmoothingType" -PropertyType DWord -Value 2 -Force | Out-Null
New-ItemProperty -Path $desktopPath -Name "FontSmoothingGamma" -PropertyType DWord -Value 1500 -Force | Out-Null
Write-Output "Enabled font smoothing (smooth edges of screen fonts)."

# 4) Show window contents while dragging
# HKCU\Control Panel\Desktop\DragFullWindows = "1" (string)
New-ItemProperty -Path $desktopPath -Name "DragFullWindows" -PropertyType String -Value "1" -Force | Out-Null
Write-Output "Set DragFullWindows=1 (show window contents while dragging)."

# Refresh Explorer shell to apply Explorer-based settings
try {
    Write-Output "Restarting Explorer to apply settings..."
    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer.exe | Out-Null
} catch {
    Write-Output "Explorer restart skipped/failed: $($_.Exception.Message)"
}

Write-Output "Compliant visual effects settings detected for user: $UserName"
Stop-Transcript | Out-Null   
exit 0