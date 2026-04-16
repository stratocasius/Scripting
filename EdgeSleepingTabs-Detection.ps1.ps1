### Edge Sleeping Tabs - Detection (HKCU policy) - 03/11/2026
### EdgeSleepingTabs-Detection.ps1
### Define Edge HKCU Key
$edgePolicy = "HKCU:\Software\Policies\Microsoft\Edge"
### Define strings
$timeoutName   = "SleepingTabsTimeoutInMinutes"
$enabledName   = "SleepingTabsEnabled"
### Define values
$desiredTimeout = "1800"   # REG_SZ
$desiredEnabled = "1"      # REG_SZ

try {
    $props = Get-ItemProperty -Path $edgePolicy -ErrorAction Stop

    $timeoutExists = $null -ne $props.$timeoutName
    $enabledExists = $null -ne $props.$enabledName

    if (-not $timeoutExists -or -not $enabledExists) {
        Write-Output "Non-compliant: One or both required values for Edge Sleep Tabs are missing."
        exit 1
    }

    $timeoutMatch = ([string]$props.$timeoutName -eq $desiredTimeout)
    $enabledMatch = ([string]$props.$enabledName -eq $desiredEnabled)

    if ($timeoutMatch -and $enabledMatch) {
        Write-Output "Compliant: SleepingTabsEnabled=1 and SleepingTabsTimeoutInMinutes=1800."
        exit 0
    }
    else {
        Write-Output "Non-compliant: Values do not match required configuration."
        exit 1
    }
}
catch {
    Write-Output "Non-compliant: Edge policy key not found or unreadable at '$edgePolicy'."
    exit 1
}