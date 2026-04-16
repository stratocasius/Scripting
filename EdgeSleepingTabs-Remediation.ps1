# Edge Sleeping Tabs - Remediation (write to interactive user's hive) - 03/11/2026
# Sets:
# HKCU\Software\Policies\Microsoft\Edge\SleepingTabsEnabled (DWORD)=1
# HKCU\Software\Policies\Microsoft\Edge\SleepingTabsTimeoutInMinutes (DWORD)=30

$ErrorActionPreference = "Stop"

function Get-InteractiveUserSid {
    try {
        $explorer = Get-Process explorer -ErrorAction Stop | Select-Object -First 1
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$($explorer.Id)" -ErrorAction Stop
        ($proc | Invoke-CimMethod -MethodName GetOwnerSid -ErrorAction Stop).Sid
    } catch { $null }
}

function Ensure-UserKey {
    param([string]$Sid,[string]$SubKey)
    $path = "Registry::HKEY_USERS\$Sid\$SubKey"
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    $path
}

try {
    $sid = Get-InteractiveUserSid
    if (-not $sid) {
        Write-Output "NoInteractiveUser|NotApplicable"
        exit 0
    }

    $subKey = "Software\Policies\Microsoft\Edge"
    $edgePolicyPath = Ensure-UserKey -Sid $sid -SubKey $subKey

    $enabledName   = "SleepingTabsEnabled"
    $timeoutName   = "SleepingTabsTimeoutInMinutes"

    $desiredEnabled = 1      # DWORD
    $desiredTimeout = 30   # DWORD (30 min, use 30)

    New-ItemProperty -Path $edgePolicyPath -Name $enabledName -PropertyType DWord -Value $desiredEnabled -Force | Out-Null
    New-ItemProperty -Path $edgePolicyPath -Name $timeoutName -PropertyType DWord -Value $desiredTimeout -Force | Out-Null

    Write-Output "Remediated|SID=$sid|$enabledName=$desiredEnabled|$timeoutName=$desiredTimeout"
    exit 0
}
catch {
    Write-Output "Failed|$($_.Exception.Message)"
    exit 1
}