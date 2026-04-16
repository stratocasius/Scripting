### VisualEffectsNerf-FullReport-Detection.ps1 - 04/05/2026
### Detection: Windows 11 Visual Effects Detection (PR) - FULL REPORT + TYPE CHECK
### Removed Font nerf elements to retain visual clarity.
# Exit 0 = Compliant, Exit 1 = Not compliant
$ErrorActionPreference = "SilentlyContinue"

$logDir = "$($env:PROGRAMDATA)\Microsoft\IntuneManagementExtension\Logs"
$detectLogPath = Join-Path $logDir "VisualEffectsNerf-Detection.log"

function Write-CMTraceLog {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet(1,2,3)][int]$Type = 1,
        [string]$Component = "VisualEffectsNerf-Detection"
    )
    $time = (Get-Date).ToString("HH:mm:ss.fff") + "+000"
    $date = (Get-Date).ToString("MM-dd-yyyy")
    $line = "<![LOG[$Message]LOG]!><time=""$time"" date=""$date"" component=""$Component"" context="""" type=""$Type"" thread=""$PID"" file=""VisualEffectsNerf-Detection5.ps1"">"
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
        $kind = $key.GetValueKind($Name)  # Microsoft.Win32.RegistryValueKind enum
        $val  = $key.GetValue($Name, $null, "DoNotExpandEnvironmentNames")
        return [pscustomobject]@{ Exists=$true; Value=$val; Type=([string]$kind); Path=$path }
    } catch {
        # Key exists but value missing OR cannot read kind
        return [pscustomobject]@{ Exists=$true; Value=$null; Type=$null; Path=$path }
    }
}

# Resolve target user SID
$Sid = Get-InteractiveUserSid
if (-not $Sid) {
    Write-CMTraceLog -Message "NoInteractiveUser|NA|NotApplicable" -Type 1
    Write-Output "NoInteractiveUser|NA|NotApplicable"
    exit 0
}

$UserName = Get-UserNameFromSid -Sid $Sid
Write-CMTraceLog -Message "Start|User=$UserName|SID=$Sid" -Type 1

# Expected settings
# NOTE: Type maps to expected registry kind:
# - DWord  -> DWord
# - String -> String
$checks = @(
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ListviewShadow";       Type="DWord";  Expected=0 },
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="IconsOnly";           Type="DWord";  Expected=0 },
    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="TaskbarAnimations";   Type="DWord";  Expected=0 },

    # VisualFXSetting intentionally excluded
    # @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; Name="VisualFXSetting"; Type="DWord"; Expected=3 },

    @{ SubKey="Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name="EnableTransparency"; Type="DWord"; Expected=0 },

    @{ SubKey="Control Panel\Desktop"; Name="DragFullWindows";     Type="String"; Expected="1" },
    @{ SubKey="Control Panel\Desktop"; Name="AnimationDuration";   Type="DWord";  Expected=0 },

    @{ SubKey="Control Panel\Desktop\WindowMetrics"; Name="MinAnimate"; Type="String"; Expected="0" }
)

$failCount = 0
$failNames = New-Object System.Collections.Generic.List[string]

foreach ($c in $checks) {
    $hkuPath = "HKU:\$Sid\$($c.SubKey)"
    $r = Get-RegValueAndType -Sid $Sid -SubKey $c.SubKey -Name $c.Name

    # Missing value
    if ($null -eq $r.Type) {
        $failCount++
        $failNames.Add($c.Name) | Out-Null
        Write-CMTraceLog -Message "FAIL|$UserName|$hkuPath|$($c.Name)=<missing>|ExpectedType=$($c.Type)|Expected=$($c.Expected)" -Type 3
        continue
    }

    # Type check (RegistryValueKind)
    # Expected kinds: DWord or String
    $expectedKind = if ($c.Type -eq "DWord") { "DWord" } else { "String" }
    $actualKind   = $r.Type  # e.g. DWord, String, ExpandString, MultiString, QWord, Binary

    if ($actualKind -ne $expectedKind) {
        $failCount++
        $failNames.Add($c.Name) | Out-Null
        Write-CMTraceLog -Message "FAIL|$UserName|$hkuPath|$($c.Name)=$($r.Value)|WrongType ActualType=$actualKind ExpectedType=$expectedKind" -Type 3
        continue
    }

    # Value check
    try {
        if ($c.Type -eq "DWord") {
            $a = [int]$r.Value
            $e = [int]$c.Expected
        } else {
            $a = [string]$r.Value
            $e = [string]$c.Expected
        }
    } catch {
        $failCount++
        $failNames.Add($c.Name) | Out-Null
        Write-CMTraceLog -Message "FAIL|$UserName|$hkuPath|$($c.Name)=<unreadable>|Type=$actualKind|Expected=$($c.Expected)" -Type 3
        continue
    }

    if ($a -ne $e) {
        $failCount++
        $failNames.Add($c.Name) | Out-Null
        Write-CMTraceLog -Message "FAIL|$UserName|$hkuPath|$($c.Name)=$a|Expected=$e|Type=$actualKind" -Type 3
    } else {
        Write-CMTraceLog -Message "PASS|$UserName|$hkuPath|$($c.Name)=$a|Type=$actualKind" -Type 1
    }
}

if ($failCount -gt 0) {
    $failList = ($failNames | Select-Object -Unique) -join ","
    Write-CMTraceLog -Message "NonCompliant|$UserName|FailCount=$failCount|Fails=$failList" -Type 3
    Write-Output ("NonCompliant|{0}|FailCount={1}|{2}" -f $UserName, $failCount, $failList)
    exit 1
}

Write-CMTraceLog -Message "Compliant|$UserName|AllSettingsOK" -Type 1
Write-Output ("Compliant|{0}|AllSettingsOK" -f $UserName)
exit 0