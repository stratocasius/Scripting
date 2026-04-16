# Remediation: Windows 11 Visual Effects Remediation - 02/19/2026
# - Disable desktop icon shadows
# - Show thumbnails instead of icons
# - Smooth edges of screen fonts
# - Show window contents while dragging
# + Disable minimize/maximize animations (MinAnimate)
# + Disable animations duration (AnimationDuration)
# + Disable taskbar animations (TaskbarAnimations)
# + Set VisualFXSetting (overall mode)
# + Disable transparency (EnableTransparency)
# Works in SYSTEM context by writing into the interactive user's hive under HKEY_USERS\<SID>

######################
# Establish transcript
$logFilepath = "$($env:PROGRAMDATA)\Microsoft\IntuneManagementExtension\Logs\VisualEffects-Remediation-Transcript.log"
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

function Get-UserNameFromSid {
    param([Parameter(Mandatory=$true)][string]$Sid)
    try {
        return ([System.Security.Principal.SecurityIdentifier]$Sid).Translate([System.Security.Principal.NTAccount]).Value
    } catch {
        return $Sid
    }
}

function Ensure-UserKey {
    param(
        [Parameter(Mandatory=$true)][string]$Sid,
        [Parameter(Mandatory=$true)][string]$SubKey
    )
    $path = "Registry::HKEY_USERS\$Sid\$SubKey"
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    return $path
}

function Set-UserRegDword {
    param(
        [Parameter(Mandatory=$true)][string]$Sid,
        [Parameter(Mandatory=$true)][string]$SubKey,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][int]$Value
    )
    $path = Ensure-UserKey -Sid $Sid -SubKey $SubKey
    New-ItemProperty -Path $path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
}

function Set-UserRegString {
    param(
        [Parameter(Mandatory=$true)][string]$Sid,
        [Parameter(Mandatory=$true)][string]$SubKey,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Value
    )
    $path = Ensure-UserKey -Sid $Sid -SubKey $SubKey
    New-ItemProperty -Path $path -Name $Name -PropertyType String -Value $Value -Force | Out-Null
}

# Resolve target user SID
$Sid = Get-InteractiveUserSid
if (-not $Sid) {
    Write-Output "No interactive user detected (explorer.exe not found). Exiting."
    Stop-Transcript | Out-Null
    exit 0
}

$UserName = Get-UserNameFromSid -Sid $Sid
Write-Output "Target interactive user: $UserName ($Sid)"

# -----------------------
# Existing settings
# -----------------------

# 1) Disable Desktop Icon Shadows
# HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ListviewShadow = 0
Set-UserRegDword -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0
Write-Output "Set ListviewShadow=0 (disable desktop icon shadows)."

# 2) Show thumbnails instead of icons
# HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\IconsOnly = 0
Set-UserRegDword -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value 0
Write-Output "Set IconsOnly=0 (show thumbnails instead of icons)."

# 3) Smooth edges of screen fonts (font smoothing)
# HKCU\Control Panel\Desktop\FontSmoothing = "2" (string)
# HKCU\Control Panel\Desktop\FontSmoothingType = 2 (DWORD)
# HKCU\Control Panel\Desktop\FontSmoothingGamma = 1500 (DWORD)
Set-UserRegString -Sid $Sid -SubKey "Control Panel\Desktop" -Name "FontSmoothing" -Value "2"
Set-UserRegDword  -Sid $Sid -SubKey "Control Panel\Desktop" -Name "FontSmoothingType" -Value 2
Set-UserRegDword  -Sid $Sid -SubKey "Control Panel\Desktop" -Name "FontSmoothingGamma" -Value 1500
Write-Output "Enabled font smoothing (smooth edges of screen fonts)."

# 4) Show window contents while dragging
# HKCU\Control Panel\Desktop\DragFullWindows = "1" (string)
Set-UserRegString -Sid $Sid -SubKey "Control Panel\Desktop" -Name "DragFullWindows" -Value "1"
Write-Output "Set DragFullWindows=1 (show window contents while dragging)."

# -----------------------
# NEW: quell animations + transparency
# -----------------------

# 5) Disable minimize/maximize animations
# HKCU\Control Panel\Desktop\WindowMetrics\MinAnimate = "0" (string) :contentReference[oaicite:5]{index=5}
Set-UserRegString -Sid $Sid -SubKey "Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0"
Write-Output "Set MinAnimate=0 (disable minimize/maximize animations)."

# 6) Disable taskbar animations
# HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarAnimations = 0 (DWORD) :contentReference[oaicite:6]{index=6}
Set-UserRegDword -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0
Write-Output "Set TaskbarAnimations=0 (disable taskbar animations)."

# 7) Visual Effects overall mode
# HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\VisualFXSetting
# Values commonly used: 2=Best performance, 3=Custom :contentReference[oaicite:7]{index=7}
# NOTE: Use Custom (3) so your explicit per-setting values (IconsOnly, ListviewShadow, etc.) aren’t stomped.
Set-UserRegDword -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3
Write-Output "Set VisualFXSetting=3 (Custom visual effects mode)."

# 8) Quell general animation duration
# HKCU\Control Panel\Desktop\AnimationDuration = 0 (DWORD) :contentReference[oaicite:8]{index=8}
Set-UserRegDword -Sid $Sid -SubKey "Control Panel\Desktop" -Name "AnimationDuration" -Value 0
Write-Output "Set AnimationDuration=0 (reduce/disable animation duration)."

# 9) Disable transparency effects
# HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\EnableTransparency = 0 (DWORD) :contentReference[oaicite:9]{index=9}
Set-UserRegDword -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0
Write-Output "Set EnableTransparency=0 (disable transparency effects)."

# Refresh Explorer shell to apply Explorer-based settings
try {
    Write-Output "Restarting Explorer to apply settings..."
    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer.exe | Out-Null
} catch {
    Write-Output "Explorer restart skipped/failed: $($_.Exception.Message)"
}

Write-Output "Compliant visual effects settings applied for user: $UserName"
Stop-Transcript | Out-Null
exit 0
