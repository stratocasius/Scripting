# Get most recent Windows Update Downloaded
$received = Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-WindowsUpdateClient/Operational'
    ID = 26
} -MaxEvents 2 -ErrorAction SilentlyContinue

# Get most recent Windows Update Installation Completed
$installed = Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-WindowsUpdateClient/Operational'
    ID = 41
} -MaxEvents 2 -ErrorAction SilentlyContinue

# Get most recent restart event
$reboot = Get-WinEvent -FilterHashtable @{
    LogName='System'
    ID=1074
} -MaxEvents 2 -ErrorAction SilentlyContinue

$receivedTime = $received.TimeCreated
$installedTime = $installed.TimeCreated
$rebootTime = $reboot.TimeCreated

# Handle missing data safely
if (-not $receivedTime) { $receivedTime = "N/A" }
if (-not $installedTime) { $installedTime = "N/A" }
if (-not $rebootTime) { $rebootTime = "N/A" }

Write-Output "Update Received: $receivedTime | Update Installed : $installedTime | Rebooted: $rebootTime"
exit 0