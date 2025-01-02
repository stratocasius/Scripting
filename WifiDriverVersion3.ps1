###########################################################
# Get information about network adapters, filter for Wi-Fi
$wifiAdapterInfo = Get-WmiObject -Class Win32_PnPSignedDriver | 
    Where-Object { $_.DeviceClass -like "*NET*" }

# Sort the adapters by driver date in descending order (newest first)
$latestWifiDriver = $wifiAdapterInfo | Sort-Object -Property DriverDate -Descending | Select-Object -First 1

# Display the latest Wi-Fi driver version and device name
if ($latestWifiDriver) {
    $deviceName = $latestWifiDriver.DeviceName
    $driverVersion = $latestWifiDriver.DriverVersion
    Write-Host "Device Name: $deviceName $driverversion"
} else {
    Write-Host "No Wi-Fi driver found."
}
