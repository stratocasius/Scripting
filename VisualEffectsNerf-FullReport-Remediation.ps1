### ### VisualEffectsNerf-FullReport-Remediation.ps1 - 04/05/2026
# Remediation: Windows 11 Visual Effects Nerf (interactive user) 
# - Disable desktop icon shadows
# - Show thumbnails instead of icons
# - Show window contents while dragging
# - Disable minimize/maximize animations (MinAnimate)
# - Disable animations duration (AnimationDuration)
# - Disable taskbar animations (TaskbarAnimations)
# - Disable transparency (EnableTransparency)
# - VisualFXSetting intentionally NOT set (commented out)
# - Edge: SleepingTabsEnabled=1, SleepingTabsTimeout=1800 (commented out)
# - Smooth edges of screen fonts (Removed)


$ErrorActionPreference = "Continue"

$logDir = "$($env:PROGRAMDATA)\Microsoft\IntuneManagementExtension\Logs"
$remLogPath = Join-Path $logDir "VisualEffectsNerf-Remediation.log"

function Write-CMTraceLog {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet(1,2,3)][int]$Type = 1,
        [string]$Component = "VisualEffectsNerf-Remediation"
    )
    $time = (Get-Date).ToString("HH:mm:ss.fff") + "+000"
    $date = (Get-Date).ToString("MM-dd-yyyy")
    $line = "<![LOG[$Message]LOG]!><time=""$time"" date=""$date"" component=""$Component"" context="""" type=""$Type"" thread=""$PID"" file=""VisualEffectsNerf-Remediation5.ps1"">"
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

function Ensure-Key {
    param([Parameter(Mandatory=$true)][string]$Path)
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        return $true
    } catch { return $false }
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

function Set-RegValueTyped {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][ValidateSet("DWord","String")][string]$ExpectedKind,
        [Parameter(Mandatory=$true)]$ExpectedValue,
        [Parameter(Mandatory=$true)][string]$IdentityTag # e.g. username/sid for logging
    )

    if (-not (Ensure-Key -Path $Path)) {
        Write-CMTraceLog -Message "FAIL|$IdentityTag|$Path|$Name|CannotCreateKey" -Type 3
        return $false
    }

    $current = Get-ValueKindAndValue -Path $Path -Name $Name
    if ($null -ne $current) {
        # Type match?
        if ($current.Kind -eq $ExpectedKind) {
            # Value match?
            try {
                if ($ExpectedKind -eq "DWord") {
                    $a = [int]$current.Value
                    $e = [int]$ExpectedValue
                } else {
                    $a = [string]$current.Value
                    $e = [string]$ExpectedValue
                }

                if ($a -eq $e) {
                    Write-CMTraceLog -Message "PASS|$IdentityTag|$Path|$Name=$a|Type=$($current.Kind)" -Type 1
                    return $true
                }
            } catch {
                # fall through to rewrite
            }
        }
    }

    # If wrong type or wrong value, remove existing value first (prevents type conflicts)
    try {
        if ($null -ne $current) {
            Remove-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue | Out-Null
        }
    } catch {}

    # Write correct typed value
    try {
        if ($ExpectedKind -eq "DWord") {
            New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value ([int]$ExpectedValue) -Force | Out-Null
            Write-CMTraceLog -Message "FIX|$IdentityTag|$Path|$Name=$ExpectedValue|Type=DWord" -Type 1
        } else {
            New-ItemProperty -Path $Path -Name $Name -PropertyType String -Value ([string]$ExpectedValue) -Force | Out-Null
            Write-CMTraceLog -Message "FIX|$IdentityTag|$Path|$Name=$ExpectedValue|Type=String" -Type 1
        }
        return $true
    } catch {
        Write-CMTraceLog -Message "FAIL|$IdentityTag|$Path|$Name|SetFailed|$($_.Exception.Message)" -Type 3
        return $false
    }
}

# -------------------------
# Start
# -------------------------
$Sid = Get-InteractiveUserSid
if (-not $Sid) {
    Write-CMTraceLog -Message "NoInteractiveUser|NA|NotApplicable" -Type 1
    exit 0
}

$UserName = Get-UserNameFromSid -Sid $Sid
$tag = "$UserName ($Sid)"
Write-CMTraceLog -Message "Start|User=$tag" -Type 1

# -------------------------
# Per-user (HKU)
# -------------------------
$hkuBase = "Registry::HKEY_USERS\$Sid"

# Explorer Advanced
Set-RegValueTyped -Path (Join-Path $hkuBase "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced") -Name "ListviewShadow"     -ExpectedKind "DWord"  -ExpectedValue 0    -IdentityTag $tag | Out-Null
Set-RegValueTyped -Path (Join-Path $hkuBase "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced") -Name "IconsOnly"         -ExpectedKind "DWord"  -ExpectedValue 0    -IdentityTag $tag | Out-Null
Set-RegValueTyped -Path (Join-Path $hkuBase "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced") -Name "TaskbarAnimations" -ExpectedKind "DWord"  -ExpectedValue 0    -IdentityTag $tag | Out-Null

# Transparency
Set-RegValueTyped -Path (Join-Path $hkuBase "Software\Microsoft\Windows\CurrentVersion\Themes\Personalize") -Name "EnableTransparency" -ExpectedKind "DWord" -ExpectedValue 0 -IdentityTag $tag | Out-Null

# Desktop
Set-RegValueTyped -Path (Join-Path $hkuBase "Control Panel\Desktop") -Name "DragFullWindows"    -ExpectedKind "String" -ExpectedValue "1"    -IdentityTag $tag | Out-Null
Set-RegValueTyped -Path (Join-Path $hkuBase "Control Panel\Desktop") -Name "AnimationDuration"  -ExpectedKind "DWord"  -ExpectedValue 0      -IdentityTag $tag | Out-Null

# WindowMetrics
Set-RegValueTyped -Path (Join-Path $hkuBase "Control Panel\Desktop\WindowMetrics") -Name "MinAnimate" -ExpectedKind "String" -ExpectedValue "0" -IdentityTag $tag | Out-Null

# VisualFXSetting intentionally NOT set:
# Set-RegValueTyped -Path (Join-Path $hkuBase "Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects") -Name "VisualFXSetting" -ExpectedKind "DWord" -ExpectedValue 3 -IdentityTag $tag | Out-Null

# -------------------------
# Edge Sleeping Tabs (HKLM policy)
# -------------------------
# $edgePolicy = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge"
# $edgeTag = "HKLM-EdgePolicy"

# Enable Sleeping Tabs
# Set-RegValueTyped -Path $edgePolicy -Name "SleepingTabsEnabled" -ExpectedKind "DWord" -ExpectedValue 1 -IdentityTag $edgeTag | Out-Null
# 1800 seconds (30 minutes)
# Set-RegValueTyped -Path $edgePolicy -Name "SleepingTabsTimeout" -ExpectedKind "DWord" -ExpectedValue 1800 -IdentityTag $edgeTag | Out-Null

# -------------------------
# Apply changes (best-effort) May look to comment out?
# -------------------------
try {
    Write-CMTraceLog -Message "Info|RestartingExplorer|BestEffort" -Type 1
    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer.exe | Out-Null
} catch {
    Write-CMTraceLog -Message "WARN|ExplorerRestartFailed|$($_.Exception.Message)" -Type 2
}

Write-CMTraceLog -Message "Complete|User=$tag" -Type 1
exit 0