# VisualEffectsRevert-Detection.ps1 - 03/02/2026
# Detection (PR) - FAST TRACK: Exit 0 = Reverted, Exit 1 = Nerf still present
$ErrorActionPreference = "SilentlyContinue"

function Get-InteractiveUserSid {
    try {
        $explorer = Get-Process explorer -ErrorAction Stop | Select-Object -First 1
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$($explorer.Id)" -ErrorAction Stop
        ($proc | Invoke-CimMethod -MethodName GetOwnerSid -ErrorAction Stop).Sid
    } catch { $null }
}

function Get-UserNameFromSid {
    param([Parameter(Mandatory=$true)][string]$Sid)
    try { ([System.Security.Principal.SecurityIdentifier]$Sid).Translate([System.Security.Principal.NTAccount]).Value }
    catch { $Sid }
}

function Get-RegValueHKU {
    param([string]$Sid,[string]$SubKey,[string]$Name)
    $path = "Registry::HKEY_USERS\$Sid\$SubKey"
    if (-not (Test-Path $path)) { return $null }
    (Get-ItemProperty -Path $path -Name $Name -ErrorAction SilentlyContinue).$Name
}

function Get-RegValueHKLM {
    param([string]$SubKey,[string]$Name)
    $path = "HKLM:\$SubKey"
    if (-not (Test-Path $path)) { return $null }
    (Get-ItemProperty -Path $path -Name $Name -ErrorAction SilentlyContinue).$Name
}

function Fail-Fast([string]$msg) { Write-Output $msg; exit 1 }

# Resolve interactive user
$Sid = Get-InteractiveUserSid
if (-not $Sid) {
    Write-Output "NoInteractiveUser|NA|NotApplicable"
    exit 0
}
$UserName = Get-UserNameFromSid -Sid $Sid

# Any of these being present (or set to nerf value) means NOT reverted yet.
$checks = @(
    # Explorer Advanced (nerf values)
    @{ Hive="HKU"; SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ListviewShadow";       Type="DWord"; Nerf=0 },
    @{ Hive="HKU"; SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="IconsOnly";           Type="DWord"; Nerf=0 },
    @{ Hive="HKU"; SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="TaskbarAnimations";   Type="DWord"; Nerf=0 },

    # Visual FX (treat presence as nerf)
    @{ Hive="HKU"; SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; Name="VisualFXSetting"; Type="DWord"; Nerf=3 },

    # Transparency
    @{ Hive="HKU"; SubKey="Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name="EnableTransparency"; Type="DWord"; Nerf=0 },

    # Desktop
    @{ Hive="HKU"; SubKey="Control Panel\Desktop"; Name="FontSmoothing";       Type="String"; Nerf="2" },
    @{ Hive="HKU"; SubKey="Control Panel\Desktop"; Name="FontSmoothingType";   Type="DWord";  Nerf=2 },
    @{ Hive="HKU"; SubKey="Control Panel\Desktop"; Name="FontSmoothingGamma";  Type="DWord";  Nerf=1500 },
    @{ Hive="HKU"; SubKey="Control Panel\Desktop"; Name="DragFullWindows";     Type="String"; Nerf="1" },
    @{ Hive="HKU"; SubKey="Control Panel\Desktop"; Name="AnimationDuration";   Type="DWord";  Nerf=0 },

    # WindowMetrics
    @{ Hive="HKU"; SubKey="Control Panel\Desktop\WindowMetrics"; Name="MinAnimate"; Type="String"; Nerf="0" },

    # Edge policies (machine level)
    @{ Hive="HKLM"; SubKey="SOFTWARE\Policies\Microsoft\Edge"; Name="SleepingTabsEnabled"; Type="DWord"; Nerf=1 },
    @{ Hive="HKLM"; SubKey="SOFTWARE\Policies\Microsoft\Edge"; Name="SleepingTabsTimeout"; Type="DWord"; Nerf=1800 }
)

foreach ($c in $checks) {
    $actual = if ($c.Hive -eq "HKU") {
        Get-RegValueHKU -Sid $Sid -SubKey $c.SubKey -Name $c.Name
    } else {
        Get-RegValueHKLM -SubKey $c.SubKey -Name $c.Name
    }

    # For REVERT detection:
    # If value is missing -> good (reverted)
    if ($null -eq $actual) { continue }

    # If present and equals nerf value -> NOT reverted
    $a = switch ($c.Type) {
        "DWord"  { [int]$actual }
        "String" { [string]$actual }
        default  { [string]$actual }
    }
    $n = switch ($c.Type) {
        "DWord"  { [int]$c.Nerf }
        "String" { [string]$c.Nerf }
        default  { [string]$c.Nerf }
    }

    if ($a -eq $n) {
        Fail-Fast ("NotReverted|{0}|{1}={2}" -f $UserName, $c.Name, $a)
    } else {
        # Value exists but is different from nerf value.
        # Still treat as reverted (user changed it) OR if you want strict removal, change this to Fail-Fast.
        continue
    }
}

Write-Output ("Reverted|{0}|NoNerfValuesFound" -f $UserName)
exit 0