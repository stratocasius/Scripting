<# 
JL – Lockscreen Timeout to 1 hour – Remediation
Run as: SYSTEM (64-bit)
Logs: C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LockscreenTimeout-1hour.log

What it sets:
  HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\InactivityTimeoutSecs = 3600 (DWORD)
  HKU\<ActiveUserSID>\Control Panel\Desktop\ScreenSaveActive        = "1"   (REG_SZ)
  HKU\<ActiveUserSID>\Control Panel\Desktop\ScreenSaverIsSecure     = "1"   (REG_SZ)
  HKU\<ActiveUserSID>\Control Panel\Desktop\ScreenSaveTimeOut       = "3600"(REG_SZ)
  HKU\<ActiveUserSID>\Control Panel\Desktop\SCRNSAVE.EXE            = "%SystemRoot%\System32\scrnsave.scr" (REG_SZ) if empty
#>

$Log = 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LockscreenTimeout-1hour.log'
New-Item -ItemType Directory -Path (Split-Path $Log -Parent) -Force | Out-Null
try { Start-Transcript -Path $Log -Append -ErrorAction SilentlyContinue | Out-Null } catch {}

function Get-ActiveUserSid {
    try {
        $explorer = Get-Process explorer -IncludeUserName -ErrorAction Stop | Sort-Object StartTime | Select-Object -Last 1
        if ($explorer.UserName) {
            $acct = New-Object System.Security.Principal.NTAccount($explorer.UserName)
            return $acct.Translate([System.Security.Principal.SecurityIdentifier]).Value
        }
    } catch {}
    return $null
}

# 1) Enforce machine inactivity limit (locks session after idle)
try {
    $lmKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    if (-not (Test-Path $lmKey)) { New-Item -Path $lmKey -Force | Out-Null }
    $current = (Get-ItemProperty -Path $lmKey -Name 'InactivityTimeoutSecs' -ErrorAction SilentlyContinue).InactivityTimeoutSecs
    Write-Output "Before: HKLM InactivityTimeoutSecs=$current"
    New-ItemProperty -Path $lmKey -Name 'InactivityTimeoutSecs' -PropertyType DWord -Value 3600 -Force | Out-Null
    $after = (Get-ItemProperty -Path $lmKey -Name 'InactivityTimeoutSecs' -ErrorAction SilentlyContinue).InactivityTimeoutSecs
    Write-Output "After:  HKLM InactivityTimeoutSecs=$after"
}
catch {
    Write-Output "ERROR setting HKLM InactivityTimeoutSecs: $($_.Exception.Message)"
}

# 2) Enforce user screensaver lock path for the actively logged-on user
$userSid = Get-ActiveUserSid
if ($userSid) {
    $hkUser = "Registry::HKEY_USERS\$userSid\Control Panel\Desktop"
    try {
        if (-not (Test-Path $hkUser)) { New-Item -Path $hkUser -Force | Out-Null }
        $before = Get-ItemProperty -Path $hkUser -ErrorAction SilentlyContinue
        Write-Output ("Before HKU {0}: ScreenSaveActive={1} ScreenSaverIsSecure={2} ScreenSaveTimeOut={3} SCRNSAVE.EXE={4}" -f `
            $userSid, $before.ScreenSaveActive, $before.ScreenSaverIsSecure, $before.ScreenSaveTimeOut, $before.'SCRNSAVE.EXE')

        New-ItemProperty -Path $hkUser -Name 'ScreenSaveActive'      -PropertyType String -Value '1'     -Force | Out-Null
        New-ItemProperty -Path $hkUser -Name 'ScreenSaverIsSecure'   -PropertyType String -Value '1'     -Force | Out-Null
        New-ItemProperty -Path $hkUser -Name 'ScreenSaveTimeOut'     -PropertyType String -Value '3600'  -Force | Out-Null

        # Ensure there is a saver set so the secure-on-resume path actually triggers when SS is used
        $scr = (Get-ItemProperty -Path $hkUser -ErrorAction SilentlyContinue).'SCRNSAVE.EXE'
        if (-not $scr -or -not (Test-Path $scr)) {
            $defaultScr = "$env:SystemRoot\System32\scrnsave.scr"
            New-ItemProperty -Path $hkUser -Name 'SCRNSAVE.EXE' -PropertyType String -Value $defaultScr -Force | Out-Null
            Write-Output "Set SCRNSAVE.EXE to $defaultScr"
        }

        $after = Get-ItemProperty -Path $hkUser -ErrorAction SilentlyContinue
        Write-Output ("After  HKU {0}: ScreenSaveActive={1} ScreenSaverIsSecure={2} ScreenSaveTimeOut={3} SCRNSAVE.EXE={4}" -f `
            $userSid, $after.ScreenSaveActive, $after.ScreenSaverIsSecure, $after.ScreenSaveTimeOut, $after.'SCRNSAVE.EXE')
    }
    catch {
        Write-Output "ERROR setting HKU values for $userSid $($_.Exception.Message)"
    }
} else {
    Write-Output "No active user detected; skipped HKU screensaver settings."
}

try { Stop-Transcript | Out-Null } catch {}
