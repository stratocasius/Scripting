# Window: last 30 days up to now
$start = (Get-Date).AddDays(-15)

# Get Windows Update "Received" events (ID 26)
$received = Get-WinEvent -FilterHashtable @{
    LogName   = 'Microsoft-Windows-WindowsUpdateClient/Operational'
    ID        = 26
    StartTime = $start
} -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 2

# Get Windows Update "Installed" events (ID 41)
$installed = Get-WinEvent -FilterHashtable @{
    LogName   = 'Microsoft-Windows-WindowsUpdateClient/Operational'
    ID        = 41
    StartTime = $start
} -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 2

# Get planned-system-triggered reboot events (ID 1074)
$reboot = Get-WinEvent -FilterHashtable @{
    LogName   = 'System'
    ID        = 1074
    StartTime = $start
} -ErrorAction SilentlyContinue |
    Where-Object { $_.Message -match 'on behalf of (user )?NT AUTHORITY\\SYSTEM.*Operating System: Service pack \(Planned\)' } |
    Sort-Object TimeCreated -Descending | Select-Object -First 2

# Extract KB from event message text (returns 'KB#######' or N/A)
function Get-KB {
    param([string]$Message)
    if ($Message -match '(KB\d{6,7})') { return $matches[1] }
    return 'N/A'
}

# Format time lists and KB numbers
function Format-Events {
    param($events)
    if (-not $events) { return "N/A" }
    return ($events | ForEach-Object {
        "$($_.TimeCreated.ToString('u')) (KB: $(Get-KB $_.Message))"
    }) -join ', '
}

$receivedFormatted  = Format-Events $received
$installedFormatted = Format-Events $installed
$rebootFormatted    = ($reboot | ForEach-Object { $_.TimeCreated.ToString('u') }) -join ', '
if (-not $rebootFormatted) { $rebootFormatted = "N/A" }

Write-Output "Received: $receivedFormatted | Installed: $installedFormatted | Rebooted (Planned): $rebootFormatted"
exit 0
