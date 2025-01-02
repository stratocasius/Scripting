# Define parameters
$outputFolder = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PerfMon"
$tempOutputFolder = "C:\Temp\PerfMonLogs"
$dcsName = "ProcessMonitoring"
$csvFileName = "PerfMonResults.csv"
$durationSeconds = 6 * 60 * 60  # 6 hours
$sampleInterval = 15            # 15 seconds

# Create necessary folders
if (-not (Test-Path $outputFolder)) {
    Write-Output "Creating output folder at $outputFolder..."
    New-Item -Path $outputFolder -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $tempOutputFolder)) {
    Write-Output "Creating temporary output folder at $tempOutputFolder..."
    New-Item -Path $tempOutputFolder -ItemType Directory -Force | Out-Null
}

# Define counters to monitor
$counters = @(
    "\Process(*)\% Processor Time",
    "\Process(*)\Private Bytes",
    "\Process(*)\IO Data Bytes/sec"
)

# Create the Data Collector Set
Write-Output "Creating the Data Collector Set..."
$collector = New-Object -ComObject Pla.DataCollectorSet
$collector.DisplayName = $dcsName
$collector.Description = "Process monitoring stats (Processor Time, Memory, IO)"
$collector.RootPath = $tempOutputFolder
$collector.Segment = 0
$collector.SegmentMaxSize = 0
$collector.SegmentMaxDuration = $durationSeconds

# Add performance counters to the Data Collector
$perfCollector = $collector.DataCollectors.Add("Performance Counter")
$perfCollector.Name = "ProcessStatsCollector"
$perfCollector.SampleInterval = $sampleInterval
foreach ($counter in $counters) {
    $perfCollector.PerformanceCounters.Add($counter)
}

# Start the Data Collector Set
Write-Output "Starting the Data Collector Set..."
$collector.Start(1)

# Wait for the monitoring duration
Write-Output "Collecting performance metrics for $durationSeconds seconds..."
Start-Sleep -Seconds $durationSeconds

# Stop the Data Collector Set
Write-Output "Stopping the Data Collector Set..."
$collector.Stop()

# Locate the binary log file (.blg) generated
$blgFile = Get-ChildItem -Path $tempOutputFolder -Filter "*.blg" | Select-Object -First 1
if (-not $blgFile) {
    Write-Error "No log file was generated."
    exit 1
}

# Export the .blg file to CSV format
Write-Output "Exporting the binary log file to CSV format..."
$csvFilePath = Join-Path -Path $tempOutputFolder -ChildPath $csvFileName
logman export -name $dcsName -xml "$($blgFile.FullName)" -csv $csvFilePath

# Copy the CSV and .blg files to the IntuneManagementExtension logs folder
Write-Output "Copying files to $outputFolder..."
Copy-Item -Path $csvFilePath -Destination $outputFolder -Force
Copy-Item -Path $blgFile.FullName -Destination $outputFolder -Force

# Clean up the temporary folder
Write-Output "Cleaning up temporary files..."
Remove-Item -Path $tempOutputFolder -Recurse -Force

Write-Output "Performance monitoring complete. Logs saved to $outputFolder."
