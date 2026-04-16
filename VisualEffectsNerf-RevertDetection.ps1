# VisualEffectsNerf-RevertDetection.ps1 - 03/04/2026
# Detection (REVERT MODE): Return to default/previous UX by ensuring "nerf-only" settings are NOT enforced.
# Exit 0 = Compliant (nothing to revert), Exit 1 = Not compliant (revert needed)

$ErrorActionPreference = "SilentlyContinue"

$logDir = "$($env:PROGRAMDATA)\Microsoft\IntuneManagementExtension\Logs"
$detectLogPath = Join-Path $logDir "VisualEffectsNerf-RevertDetection.log"

function Write-CMTraceLog {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet(1,2,3)][int]$Type = 1,
        [string]$Component = "VisualEffectsNerf-RevertDetection"
    )
    $time = (Get-Date).ToString("HH:mm:ss.fff") + "+000"
    $date = (Get-Date).ToString("MM-dd-yyyy")
    $line = "<![LOG[$Message]LOG]!><time=""$time"" date=""$date"" component=""$Component"" context="""" type=""$Type"" thread=""$PID"" file=""VisualEffectsNerf-RevertDetection.ps1"">"
    Add-Content -Path $detectLogPath -Value $line -Encoding UTF8
}

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

function Get-RegValueAndType {
    param(
        [Parameter(Mandatory=$true)][string]$Sid,
        [Parameter(Mandatory=$true)][string]$SubKey,
        [Parameter(Mandatory=$true)][string]$Name
    )

    $path = "Registry::HKEY_USERS\$Sid\$SubKey"
    if (-not (Test-Path $path)) {
        return [pscustomobject]@{ Exists=$false; Value=$null; Type=$null; Path=$path }
    }

    try {
        $key = Get-Item -Path $path -ErrorAction Stop
        $kind = $key.GetValueKind($Name)
        $val  = $key.GetValue($Name, $null, "DoNotExpandEnvironmentNames")
        return [pscustomobject]@{ Exists=$true; Value=$val; Type=([string]$kind); Path=$path }
    } catch {
        return [pscustomobject]@{ Exists=$true; Value=$null; Type=$null; Path=$path }
    }
}

# -------------------------
# Start
# -------------------------
$Sid = Get-InteractiveUserSid
if (-not $Sid) {
    Write-CMTraceLog -Message "NoInteractiveUser|NA|NotApplicable" -Type 1
    Write-Output "NoInteractiveUser|NA|NotApplicable"
    exit 0
}

$UserName = Get-UserNameFromSid -Sid $Sid
Write-CMTraceLog -Message "Start|User=$UserName|SID=$Sid" -Type 1

# Settings list:
# - IsNerfOnly = $true means we FAIL if the value is currently enforcing the nerf state.
# - IsNerfOnly = $false means we report it, but do NOT affect compliance.
$checks = @(
    # Nerf-only settings (these drive compliance in revert mode)
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced";           Name="ListviewShadow";     ExpectedKind="DWord";  NerfValue=0;     IsNerfOnly=$true  },
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced";           Name="TaskbarAnimations"; ExpectedKind="DWord";  NerfValue=0;     IsNerfOnly=$true  },
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Themes\Personalize";          Name="EnableTransparency";ExpectedKind="DWord";  NerfValue=0;     IsNerfOnly=$true  },
    @{ SubKey="Control Panel\Desktop";                                                Name="AnimationDuration"; ExpectedKind="DWord";  NerfValue=0;     IsNerfOnly=$true  },
    @{ SubKey="Control Panel\Desktop\WindowMetrics";                                  Name="MinAnimate";        ExpectedKind="String"; NerfValue="0";   IsNerfOnly=$true  },

    # Report-only (tracked previously, but not safe to gate revert compliance due to defaults/user prefs)
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced";           Name="IconsOnly";         ExpectedKind="DWord";  NerfValue=0;     IsNerfOnly=$false },
    @{ SubKey="Control Panel\Desktop";                                                Name="FontSmoothing";     ExpectedKind="String"; NerfValue="2";   IsNerfOnly=$false },
    @{ SubKey="Control Panel\Desktop";                                                Name="FontSmoothingType"; ExpectedKind="DWord";  NerfValue=2;     IsNerfOnly=$false },
    @{ SubKey="Control Panel\Desktop";                                                Name="FontSmoothingGamma";ExpectedKind="DWord";  NerfValue=1500;  IsNerfOnly=$false },
    @{ SubKey="Control Panel\Desktop";                                                Name="DragFullWindows";   ExpectedKind="String"; NerfValue="1";   IsNerfOnly=$false }
)

$revertNeeded = 0
$reportLines = New-Object System.Collections.Generic.List[string]

foreach ($c in $checks) {
    $hkuPath = "HKU:\$Sid\$($c.SubKey)"
    $r = Get-RegValueAndType -Sid $Sid -SubKey $c.SubKey -Name $c.Name

    if (-not $r.Exists) {
        Write-CMTraceLog -Message "INFO|$UserName|$hkuPath|$($c.Name)=<keymissing>" -Type 1
        $reportLines.Add("$($c.Name)=<keymissing>") | Out-Null
        continue
    }

    if ($null -eq $r.Type) {
        Write-CMTraceLog -Message "INFO|$UserName|$hkuPath|$($c.Name)=<valuemissing>" -Type 1
        $reportLines.Add("$($c.Name)=<valuemissing>") | Out-Null
        continue
    }

    $actualKind = $r.Type
    $val = $r.Value

    # Normalize comparisons for DWord/String
    $isMatch = $false
    try {
        if ($c.ExpectedKind -eq "DWord") {
            $isMatch = ($actualKind -eq "DWord" -and ([int]$val -eq [int]$c.NerfValue))
        } else {
            $isMatch = ($actualKind -eq "String" -and ([string]$val -eq [string]$c.NerfValue))
        }
    } catch {
        $isMatch = $false
    }

    if ($c.IsNerfOnly -and $isMatch) {
        # In revert-mode, this means "still nerfed" => revert needed
        $revertNeeded++
        Write-CMTraceLog -Message "FAIL|$UserName|$hkuPath|$($c.Name)=$val|Type=$actualKind|StillNerfed" -Type 3
        $reportLines.Add("$($c.Name)=$val($actualKind)-StillNerfed") | Out-Null
    } else {
        # PASS (either not present, different value, or report-only)
        $label = if ($c.IsNerfOnly) { "PASS" } else { "INFO" }
        Write-CMTraceLog -Message "$label|$UserName|$hkuPath|$($c.Name)=$val|Type=$actualKind" -Type 1
        $reportLines.Add("$($c.Name)=$val($actualKind)") | Out-Null
    }
}

if ($revertNeeded -gt 0) {
    Write-CMTraceLog -Message "NonCompliant-RevertNeeded|$UserName|Count=$revertNeeded" -Type 3
    Write-Output ("RevertNeeded|{0}|Count={1}" -f $UserName, $revertNeeded)
    exit 1
}

Write-CMTraceLog -Message "Compliant-RevertedState|$UserName|NoNerfEnforcementDetected" -Type 1
Write-Output ("RevertedOK|{0}|NoNerfEnforcementDetected" -f $UserName)
exit 0