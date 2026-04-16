# Edge Sleeping Tabs - Detection (SYSTEM-safe, checks interactive user's HKU) - 03/11/2026
# Exit 0 = Compliant, Exit 1 = NonCompliant

$ErrorActionPreference = "SilentlyContinue"

function Get-InteractiveUserSid {
    try {
        $explorer = Get-Process explorer -ErrorAction Stop | Select-Object -First 1
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$($explorer.Id)" -ErrorAction Stop
        ($proc | Invoke-CimMethod -MethodName GetOwnerSid -ErrorAction Stop).Sid
    } catch { $null }
}

function Get-RegValueAndKind {
    param(
        [Parameter(Mandatory=$true)][string]$Sid,
        [Parameter(Mandatory=$true)][string]$SubKey,
        [Parameter(Mandatory=$true)][string]$Name
    )
    $path = "Registry::HKEY_USERS\$Sid\$SubKey"
    if (-not (Test-Path $path)) {
        return [pscustomobject]@{ Exists=$false; Path=$path; Name=$Name; Kind=$null; Value=$null }
    }
    try {
        $key  = Get-Item -Path $path -ErrorAction Stop
        $kind = $key.GetValueKind($Name)
        $val  = $key.GetValue($Name, $null, "DoNotExpandEnvironmentNames")
        return [pscustomobject]@{ Exists=$true; Path=$path; Name=$Name; Kind=([string]$kind); Value=$val }
    } catch {
        return [pscustomobject]@{ Exists=$true; Path=$path; Name=$Name; Kind=$null; Value=$null }
    }
}

$sid = Get-InteractiveUserSid
if (-not $sid) {
    Write-Output "NoInteractiveUser|NotApplicable"
    exit 0
}

$subKey = "Software\Policies\Microsoft\Edge"
$enabledName = "SleepingTabsEnabled"
$timeoutName = "SleepingTabsTimeoutInMinutes"

# Expected DWORD values (matches the remediation)
$expectedEnabled = 1
$expectedTimeout = 30   # minutes (30 hours). If you intended 30 minutes, change to 30.

$checks = @(
    @{ Name=$enabledName; ExpectedKind="DWord"; ExpectedValue=$expectedEnabled },
    @{ Name=$timeoutName; ExpectedKind="DWord"; ExpectedValue=$expectedTimeout }
)

$fail = @()

foreach ($c in $checks) {
    $r = Get-RegValueAndKind -Sid $sid -SubKey $subKey -Name $c.Name
    $hkuPath = "HKU:\$sid\$subKey"

    if ($null -eq $r.Kind) {
        $fail += "$($c.Name)=<missing>"
        Write-Output "FAIL|$hkuPath|$($c.Name)=<missing>|ExpectedType=$($c.ExpectedKind)|Expected=$($c.ExpectedValue)"
        continue
    }

    if ($r.Kind -ne $c.ExpectedKind) {
        $fail += "$($c.Name)=WrongType($($r.Kind))"
        Write-Output "FAIL|$hkuPath|$($c.Name)=$($r.Value)|ActualType=$($r.Kind)|ExpectedType=$($c.ExpectedKind)"
        continue
    }

    try { $actual = [int]$r.Value } catch { $actual = $null }

    if ($null -eq $actual -or $actual -ne [int]$c.ExpectedValue) {
        $fail += "$($c.Name)=$actual"
        Write-Output "FAIL|$hkuPath|$($c.Name)=$actual|Expected=$($c.ExpectedValue)|Type=$($r.Kind)"
        continue
    }

    Write-Output "PASS|$hkuPath|$($c.Name)=$actual|Type=$($r.Kind)"
}

if ($fail.Count -gt 0) {
    Write-Output ("NonCompliant|SID={0}|{1}" -f $sid, (($fail | Select-Object -Unique) -join ","))
    exit 1
}

Write-Output ("Compliant|SID={0}|AllSettingsOK" -f $sid)
exit 0