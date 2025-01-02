# Define the network adapter name (modify this)
$networkAdapterName = "Ethernet"

# Define the monitoring interval in seconds
$monitoringInterval = 10

# Define the total monitoring duration in seconds
$monitoringDuration = 60

# Initialize variables
$totalBytesTransmitted = 0
$totalBytesReceived = 0
$startTime = Get-Date

# Loop to monitor network adapter statistics
while ((Get-Date) -lt ($startTime.AddSeconds($monitoringDuration))) {
    $adapter = Get-WmiObject -Class Win32_PerfFormattedData_Tcpip_NetworkInterface | Where-Object { $_.Name -eq $networkAdapterName }

    if ($adapter) {
        $totalBytesTransmitted += $adapter.BytesTransmittedPersec
        $totalBytesReceived += $adapter.BytesReceivedPersec
    }

    Start-Sleep -Seconds $monitoringInterval
}

# Calculate average throughput
$averageThroughputTransmit = $totalBytesTransmitted / $monitoringDuration
$averageThroughputReceive = $totalBytesReceived / $monitoringDuration

# Display the results
Write-Host "Average Throughput (Transmit): $($averageThroughputTransmit) bytes per second"
Write-Host "Average Throughput (Receive): $($averageThroughputReceive) bytes per second"
