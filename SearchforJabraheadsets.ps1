# Search for Jabra headsets
$jabraHeadsets = Get-WmiObject -Class Win32_USBHub | Where-Object {$_.Description -like "*Jabra*"}

# Check if Jabra headset is present
if ($jabraHeadsets) {
    Write-Host "Jabra headset is installed."
} else {
    Write-Host "Jabra headset is not installed."
}


Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }, Friendly


# Search for USB devices matching Jabra friendly name
$jabraDevices = Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' -and $_.FriendlyName -like "*Jabra*" }

# Check if Jabra headset is present
if ($jabraDevices) {
    Write-Host "Jabra headset is installed."
    foreach ($device in $jabraDevices) {
        Write-Host "Device Friendly Name: $($device.FriendlyName)"
        Write-Host "Device Instance ID: $($device.InstanceId)"
        Write-Host "---"
    }
} else {
    Write-Host "Jabra headset is not installed."
}