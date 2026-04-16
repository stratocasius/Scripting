# Remediation: Windows 11 Visual Effects Remediation - 03/02/2026
# - Disable desktop icon shadows
# - Show thumbnails instead of icons
# - Smooth edges of screen fonts
# - Show window contents while dragging
# + Disable minimize/maximize animations (MinAnimate)
# + Disable animations duration (AnimationDuration)
# + Disable taskbar animations (TaskbarAnimations)
# + Set VisualFXSetting (overall mode) [commented out]
# + Disable transparency (EnableTransparency)
# Works in SYSTEM context by writing into the interactive user's hive under HKEY_USERS\<SID>
$ErrorActionPreference = 'SilentlyContinue'

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

function Fail-Fast {
    param([string]$Msg)
    Write-Output $Msg
    exit 1
}

function Get-RegValue {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Name
    )
    try {
        (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
    } catch { $null }
}

# Resolve target user SID
$Sid = Get-InteractiveUserSid
if (-not $Sid) {
    Write-Output "NoInteractiveUser"
    exit 0
}

$UserName = Get-UserNameFromSid -Sid $Sid

# -----------------------
# User hive checks (HKU\<SID>\...)
# -----------------------

$advPath = "Registry::HKEY_USERS\$Sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$deskPath = "Registry::HKEY_USERS\$Sid\Control Panel\Desktop"
$wmPath   = "Registry::HKEY_USERS\$Sid\Control Panel\Desktop\WindowMetrics"
$persPath = "Registry::HKEY_USERS\$Sid\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

# 1) ListviewShadow = 0
$v = Get-RegValue -Path $advPath -Name "ListviewShadow"
if ($v -ne 0) { Fail-Fast "NonCompliant|$UserName|ListviewShadow=$v" }

# 2) IconsOnly = 0
$v = Get-RegValue -Path $advPath -Name "IconsOnly"
if ($v -ne 0) { Fail-Fast "NonCompliant|$UserName|IconsOnly=$v" }

# 3) Font smoothing: FontSmoothing="2", FontSmoothingType=2, FontSmoothingGamma=1500
$v = Get-RegValue -Path $deskPath -Name "FontSmoothing"
if ($v -ne "2") { Fail-Fast "NonCompliant|$UserName|FontSmoothing=$v" }

$v = Get-RegValue -Path $deskPath -Name "FontSmoothingType"
if ($v -ne 2) { Fail-Fast "NonCompliant|$UserName|FontSmoothingType=$v" }

$v = Get-RegValue -Path $deskPath -Name "FontSmoothingGamma"
if ($v -ne 1500) { Fail-Fast "NonCompliant|$UserName|FontSmoothingGamma=$v" }

# 4) DragFullWindows="1"
$v = Get-RegValue -Path $deskPath -Name "DragFullWindows"
if ($v -ne "1") { Fail-Fast "NonCompliant|$UserName|DragFullWindows=$v" }

# 5) MinAnimate="0"
$v = Get-RegValue -Path $wmPath -Name "MinAnimate"
if ($v -ne "0") { Fail-Fast "NonCompliant|$UserName|MinAnimate=$v" }

# 6) TaskbarAnimations=0
$v = Get-RegValue -Path $advPath -Name "TaskbarAnimations"
if ($v -ne 0) { Fail-Fast "NonCompliant|$UserName|TaskbarAnimations=$v" }

# 7) VisualFXSetting intentionally NOT checked
# $vfxPath = "Registry::HKEY_USERS\$Sid\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
# $v = Get-RegValue -Path $vfxPath -Name "VisualFXSetting"
# if ($v -ne 3) { Fail-Fast "NonCompliant|$UserName|VisualFXSetting=$v" }

# 8) AnimationDuration=0
$v = Get-RegValue -Path $deskPath -Name "AnimationDuration"
if ($v -ne 0) { Fail-Fast "NonCompliant|$UserName|AnimationDuration=$v" }

# 9) EnableTransparency=0
$v = Get-RegValue -Path $persPath -Name "EnableTransparency"
if ($v -ne 0) { Fail-Fast "NonCompliant|$UserName|EnableTransparency=$v" }

# -----------------------
# Microsoft Edge Sleeping Tabs (Policy - Machine Level)
# -----------------------

function Ensure-MachineKey {
    param([Parameter(Mandatory=$true)][string]$SubKey)
    $path = "Registry::HKEY_LOCAL_MACHINE\$SubKey"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    return $path
}

function Set-MachineRegDword {
    param(
        [Parameter(Mandatory=$true)][string]$SubKey,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][int]$Value
    )
    $path = Ensure-MachineKey -SubKey $SubKey
    New-ItemProperty -Path $path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
}

$edgePolicyKey = "SOFTWARE\Policies\Microsoft\Edge"

# Enable Sleeping Tabs
Set-MachineRegDword -SubKey $edgePolicyKey -Name "SleepingTabsEnabled" -Value 1

# Set timeout to 1800 seconds (30 minutes)
Set-MachineRegDword -SubKey $edgePolicyKey -Name "SleepingTabsTimeout" -Value 1800

Write-Output "Visual Effects EcoMode configured successfully."
Exit 0