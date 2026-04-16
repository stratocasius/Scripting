# Detection: Windows 11 Visual Effects Detection (PR) - includes animations + transparency
# Exit 0 = Compliant, Exit 1 = Not compliant
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

function Get-RegValue {
    param(
        [Parameter(Mandatory=$true)][string]$Sid,
        [Parameter(Mandatory=$true)][string]$SubKey,
        [Parameter(Mandatory=$true)][string]$Name
    )
    $path = "Registry::HKEY_USERS\$Sid\$SubKey"
    if (-not (Test-Path $path)) { return $null }
    (Get-ItemProperty -Path $path -Name $Name -ErrorAction SilentlyContinue).$Name
}

# Resolve target user SID
$Sid = Get-InteractiveUserSid
if (-not $Sid) {
    Write-Output "NoInteractiveUser|NA|NotApplicable"
    exit 0
}

$UserName = Get-UserNameFromSid -Sid $Sid

# Expected settings (Path, Name, Type, ExpectedValue)
$checks = @(
    # Explorer Advanced
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ListviewShadow";      Type="DWord";  Expected=0 },
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="IconsOnly";          Type="DWord";  Expected=0 },
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="TaskbarAnimations";  Type="DWord";  Expected=0 },

    # Visual Effects mode
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; Name="VisualFXSetting"; Type="DWord"; Expected=3 },

    # Transparency
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name="EnableTransparency"; Type="DWord"; Expected=0 },

    # Desktop
    @{ SubKey="Control Panel\Desktop"; Name="FontSmoothing";      Type="String"; Expected="2" },
    @{ SubKey="Control Panel\Desktop"; Name="FontSmoothingType";  Type="DWord";  Expected=2 },
    @{ SubKey="Control Panel\Desktop"; Name="FontSmoothingGamma"; Type="DWord";  Expected=1500 },
    @{ SubKey="Control Panel\Desktop"; Name="DragFullWindows";    Type="String"; Expected="1" },
    @{ SubKey="Control Panel\Desktop"; Name="AnimationDuration";  Type="DWord";  Expected=0 },

    # WindowMetrics
    @{ SubKey="Control Panel\Desktop\WindowMetrics"; Name="MinAnimate"; Type="String"; Expected="0" }
)

$bad = New-Object System.Collections.Generic.List[string]

foreach ($c in $checks) {
    $actual = Get-RegValue -Sid $Sid -SubKey $c.SubKey -Name $c.Name

    if ($null -eq $actual) {
        $bad.Add("$($c.Name)=<missing>") | Out-Null
        continue
    }

    # Normalize comparison by type
    switch ($c.Type) {
        "DWord"  { $a = [int]$actual;   $e = [int]$c.Expected }
        "String" { $a = [string]$actual; $e = [string]$c.Expected }
        default  { $a = [string]$actual; $e = [string]$c.Expected }
    }

    if ($a -ne $e) {
        $bad.Add("$($c.Name)=$a (exp $e)") | Out-Null
    }
}

if ($bad.Count -gt 0) {
    # One-line output for PR
    Write-Output ("NonCompliant|{0}|{1}" -f $UserName, ($bad -join "; "))
    exit 1
} else {
    Write-Output ("Compliant|{0}|AllSettingsOK" -f $UserName)
    exit 0
}