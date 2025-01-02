# PowerShell Script to check if WWAHost process is running
$processName = "CloudExperienceHostBroker"

# Get the process with the name
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($process) {
    Write-Output "ESP-active"
    exit 0
} else {
    Write-Output "ESP-not-active"
    exit 0
}