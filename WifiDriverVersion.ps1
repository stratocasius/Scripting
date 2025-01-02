######################################################################################################################
# Get information about network adapters, filter for Wi-Fi
$wifiAdapterInfo = Get-WmiObject -Class Win32_PnPSignedDriver | 
    Where-Object { $_.DeviceName -like "*Wi-Fi*" }

# Sort the adapters by driver date in descending order (newest first)
$latestWifiDriver = $wifiAdapterInfo | Sort-Object -Property DriverDate -Descending | Select-Object -First 1

# Display the latest Wi-Fi driver version
if ($latestWifiDriver) {
    Write-Host "Latest Wi-Fi Driver Version: $($latestWifiDriver.DriverVersion)"
} else {
    Write-Host "No Wi-Fi driver found."
}
