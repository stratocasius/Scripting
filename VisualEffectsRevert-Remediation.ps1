# VisualEffectsRevert-Remediation.ps1 - 03/02/2026
# Removes "nerf" values so Windows/Edge return to defaults (unmanaged/user choice)
$ErrorActionPreference = "SilentlyContinue"

$logFilepath = "$($env:PROGRAMDATA)\Microsoft\IntuneManagementExtension\Logs\VisualEffects-Revert-Transcript.log"
Start-Transcript -Append $logFilepath | Out-Null

function Get-InteractiveUserSid {
    try {
        $explorer = Get-Process explorer -ErrorAction Stop | Select-Object -First 1
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$($explorer.Id)" -ErrorAction Stop
        ($proc | Invoke-CimMethod -MethodName GetOwnerSid -ErrorAction Stop).Sid
    } catch { $null }
}

function Get-UserNameFromSid {
    param([string]$Sid)
    try { ([System.Security.Principal.SecurityIdentifier]$Sid).Translate([System.Security.Principal.NTAccount]).Value }
    catch { $Sid }
}

function Remove-UserValue {
    param([string]$Sid,[string]$SubKey,[string]$Name)
    $path = "Registry::HKEY_USERS\$Sid\$SubKey"
    if (Test-Path $path) {
        Remove-ItemProperty -Path $path -Name $Name -ErrorAction SilentlyContinue
    }
}

function Remove-MachineValue {
    param([string]$SubKey,[string]$Name)
    $path = "HKLM:\$SubKey"
    if (Test-Path $path) {
        Remove-ItemProperty -Path $path -Name $Name -ErrorAction SilentlyContinue
    }
}

$Sid = Get-InteractiveUserSid
if (-not $Sid) {
    Write-Output "No interactive user detected (explorer.exe not found). Nothing to revert."
    Stop-Transcript | Out-Null
    exit 0
}

$UserName = Get-UserNameFromSid -Sid $Sid
Write-Output "Reverting nerf settings for: $UserName ($Sid)"

# HKU\<SID> removals (revert to defaults)
Remove-UserValue -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow"
Remove-UserValue -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly"
Remove-UserValue -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations"

# VisualFXSetting (remove if ever applied)
Remove-UserValue -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting"

# Transparency
Remove-UserValue -Sid $Sid -SubKey "Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency"

# Desktop / Animation / Smoothing
Remove-UserValue -Sid $Sid -SubKey "Control Panel\Desktop" -Name "FontSmoothing"
Remove-UserValue -Sid $Sid -SubKey "Control Panel\Desktop" -Name "FontSmoothingType"
Remove-UserValue -Sid $Sid -SubKey "Control Panel\Desktop" -Name "FontSmoothingGamma"
Remove-UserValue -Sid $Sid -SubKey "Control Panel\Desktop" -Name "DragFullWindows"
Remove-UserValue -Sid $Sid -SubKey "Control Panel\Desktop" -Name "AnimationDuration"
Remove-UserValue -Sid $Sid -SubKey "Control Panel\Desktop\WindowMetrics" -Name "MinAnimate"

Write-Output "Removed user visual-effects overrides (Windows should fall back to defaults/user choices)."

# Edge policies (HKLM) removals (revert Edge to unmanaged defaults)
Remove-MachineValue -SubKey "SOFTWARE\Policies\Microsoft\Edge" -Name "SleepingTabsEnabled"
Remove-MachineValue -SubKey "SOFTWARE\Policies\Microsoft\Edge" -Name "SleepingTabsTimeout"
Write-Output "Removed Edge Sleeping Tabs policy values (Edge returns to default behavior)."

# Optional cleanup: if Edge policy key is empty, remove it (safe)
try {
    $edgeKey = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    if (Test-Path $edgeKey) {
        if (-not (Get-ItemProperty -Path $edgeKey -ErrorAction SilentlyContinue | Select-Object -ExcludeProperty PS* | Get-Member -MemberType NoteProperty)) {
            # Key has no values (only PS* props). Remove it.
            Remove-Item -Path $edgeKey -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
} catch {}

# Restart Explorer so UI re-reads some settings
try {
    Write-Output "Restarting Explorer..."
    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
    Start-Process explorer.exe | Out-Null
} catch {}

Write-Output "Revert complete for user: $UserName"
Stop-Transcript | Out-Null
exit 0