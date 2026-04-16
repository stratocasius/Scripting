# Detection: Windows 11 Visual Effects Detection - 02/19/2026
# Same checks as remediation; outputs friendly username instead of SID.
# Establish transcript
$logFilepath = "$($env:PROGRAMDATA)\Microsoft\IntuneManagementExtension\Logs\VisualEffects-Detection-Transcript.log"
# Track script duration
$global:ScriptStartTime = Get-Date
### Start logging
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

function Sid-ToUser {
    param([Parameter(Mandatory=$true)][string]$Sid)
    try {
        $sidObj = New-Object System.Security.Principal.SecurityIdentifier($Sid)
        $nt = $sidObj.Translate([System.Security.Principal.NTAccount])
        return $nt.Value  # e.g. DOMAIN\User
    } catch {
        return $Sid  # fallback to SID if translation fails
    }
}

function Get-RegValue {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Name
    )
    try {
        if (-not (Test-Path $Path)) { return $null }
        $p = Get-ItemProperty -Path $Path -ErrorAction Stop
        return $p.$Name
    } catch {
        return $null
    }
}

$Sid = Get-InteractiveUserSid
if (-not $Sid) {
    Write-Output "No interactive user detected (explorer.exe not found). Nothing to evaluate."
    exit 0
}

$UserName = Sid-ToUser -Sid $Sid

$issues = New-Object System.Collections.Generic.List[string]

# Paths
$advPath  = "Registry::HKEY_USERS\$Sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$deskPath = "Registry::HKEY_USERS\$Sid\Control Panel\Desktop"

# 1) Disable Desktop Icon shadows: ListviewShadow = 0 (DWORD)
$listviewShadow = Get-RegValue -Path $advPath -Name "ListviewShadow"
if ($listviewShadow -ne 0) {
    $issues.Add("ListviewShadow expected 0, found '$listviewShadow'")
}

# 2) Show thumbnails instead of icons: IconsOnly = 0 (DWORD)
$iconsOnly = Get-RegValue -Path $advPath -Name "IconsOnly"
if ($iconsOnly -ne 0) {
    $issues.Add("IconsOnly expected 0, found '$iconsOnly'")
}

# 3) Smooth edges of screen fonts
$fontSmoothing = Get-RegValue -Path $deskPath -Name "FontSmoothing"
if ($fontSmoothing -ne "2") {
    $issues.Add("FontSmoothing expected '2', found '$fontSmoothing'")
}

$fontSmoothingType = Get-RegValue -Path $deskPath -Name "FontSmoothingType"
if ($fontSmoothingType -ne 2) {
    $issues.Add("FontSmoothingType expected 2, found '$fontSmoothingType'")
}

# 4) Show window contents while dragging: DragFullWindows = "1" (string)
$dragFullWindows = Get-RegValue -Path $deskPath -Name "DragFullWindows"
if ($dragFullWindows -ne "1") {
    $issues.Add("DragFullWindows expected '1', found '$dragFullWindows'")
}

if ($issues.Count -gt 0) {
    Write-Output "Non-compliant visual effects settings detected for user: $UserName"
    $issues | ForEach-Object { Write-Output " - $_" }
    exit 1
}

Write-Output "Compliant visual effects settings detected for user: $UserName"
Stop-Transcript | Out-Null
exit 0
