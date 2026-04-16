# VisualEffectsNerf-RevertRemediation.ps1 - 03/03/2026
# Remediation (REVERT MODE): Remove nerf enforcement values (best practice: remove rather than guess defaults).
# - ListviewShadow
# - TaskbarAnimations
# - EnableTransparency
# - AnimationDuration
# - MinAnimate
# VisualFXSetting not managed.

$ErrorActionPreference = "Continue"

$logDir = "$($env:PROGRAMDATA)\Microsoft\IntuneManagementExtension\Logs"
$remLogPath = Join-Path $logDir "VisualEffectsNerf-RevertRemediation.log"

[int]$FixCount  = 0
[int]$FailCount = 0

function Write-CMTraceLog {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet(1,2,3)][int]$Type = 1,
        [string]$Component = "VisualEffectsNerf-RevertRemediation"
    )
    $time = (Get-Date).ToString("HH:mm:ss.fff") + "+000"
    $date = (Get-Date).ToString("MM-dd-yyyy")
    $line = "<![LOG[$Message]LOG]!><time=""$time"" date=""$date"" component=""$Component"" context="""" type=""$Type"" thread=""$PID"" file=""VisualEffectsNerf-RevertRemediation.ps1"">"
    Add-Content -Path $remLogPath -Value $line -Encoding UTF8
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

function Get-ValueKindAndValue {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Name
    )
    if (-not (Test-Path $Path)) { return $null }
    try {
        $k = Get-Item -Path $Path -ErrorAction Stop
        $kind = $k.GetValueKind($Name)
        $val  = $k.GetValue($Name, $null, "DoNotExpandEnvironmentNames")
        return [pscustomobject]@{ Kind=[string]$kind; Value=$val }
    } catch {
        return $null
    }
}

function Remove-ValueIfPresent {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$UserTag
    )
    if (-not (Test-Path $Path)) {
        Write-CMTraceLog -Message "PASS|$UserTag|$Path|$Name=<keymissing>" -Type 1
        return $true
    }

    $cur = Get-ValueKindAndValue -Path $Path -Name $Name
    if ($null -eq $cur) {
        Write-CMTraceLog -Message "PASS|$UserTag|$Path|$Name=<valuemissing>" -Type 1
        return $true
    }

    try {
        Remove-ItemProperty -Path $Path -Name $Name -ErrorAction Stop | Out-Null
        $script:FixCount++
        Write-CMTraceLog -Message "FIX|$UserTag|$Path|Removed $Name (was $($cur.Value) Type=$($cur.Kind))" -Type 1
        return $true
    } catch {
        $script:FailCount++
        Write-CMTraceLog -Message "FAIL|$UserTag|$Path|RemoveFailed $Name|$($_.Exception.Message)" -Type 3
        return $false
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
$tag = "$UserName ($Sid)"
Write-CMTraceLog -Message "Start|User=$tag" -Type 1

$hkuBase = "Registry::HKEY_USERS\$Sid"

# Nerf-only keys to remove (revert)
Remove-ValueIfPresent -Path (Join-Path $hkuBase "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")        -Name "ListviewShadow"      -UserTag $tag | Out-Null
Remove-ValueIfPresent -Path (Join-Path $hkuBase "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")        -Name "TaskbarAnimations"  -UserTag $tag | Out-Null
Remove-ValueIfPresent -Path (Join-Path $hkuBase "Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")       -Name "EnableTransparency" -UserTag $tag | Out-Null
Remove-ValueIfPresent -Path (Join-Path $hkuBase "Control Panel\Desktop")                                             -Name "AnimationDuration"  -UserTag $tag | Out-Null
Remove-ValueIfPresent -Path (Join-Path $hkuBase "Control Panel\Desktop\WindowMetrics")                               -Name "MinAnimate"         -UserTag $tag | Out-Null

# Best-effort apply
try {
    Write-CMTraceLog -Message "Info|RestartingExplorer|BestEffort" -Type 1
    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer.exe | Out-Null
} catch {
    Write-CMTraceLog -Message "WARN|ExplorerRestartFailed|$($_.Exception.Message)" -Type 2
}

Write-CMTraceLog -Message "Summary|User=$tag|FixCount=$FixCount|FailCount=$FailCount" -Type $(if ($FailCount -gt 0) {3} else {1})

if ($FailCount -gt 0) {
    Write-Output ("RevertRemediatedWithErrors|{0}|FixCount={1}|FailCount={2}" -f $UserName, $FixCount, $FailCount)
    exit 1
}

Write-Output ("Reverted|{0}|FixCount={1}|FailCount={2}" -f $UserName, $FixCount, $FailCount)
exit 0