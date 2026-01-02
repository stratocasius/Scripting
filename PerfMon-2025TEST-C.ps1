# Variables
$basePath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PerfMon-2025"
$blgFilePath = "$basePath\$env:COMPUTERNAME-DataCollector.blg"
$csvFilePath = "$basePath\$env:COMPUTERNAME-DataCollector.csv"
$dataCollectorSetName = "PerfMon-2025"
$samplingInterval = 30 # Sampling interval in seconds
$duration = 21600 # Duration in seconds

# Ensure base directory exists
Write-Output "Ensuring directory exists: $basePath"
if (-not (Test-Path -Path $basePath)) {
    New-Item -Path $basePath -ItemType Directory -Force | Out-Null
}

# Define counters
$counters = @(
    "\Process(chrome)\% Processor Time",
    "\Process(chrome)\IO Data Bytes/sec",
    "\Process(chrome)\Private Bytes",
    "\Process(IntappTime)\% Processor Time",
    "\Process(IntappTime)\IO Data Bytes/sec",
    "\Process(IntappTime)\Private Bytes",
    "\Process(IntappTimeDesktopExtension)\% Processor Time",
    "\Process(IntappTimeDesktopExtension)\IO Data Bytes/sec",
    "\Process(IntappTimeDesktopExtension)\Private Bytes",
    "\Process(reciever)\% Processor Time",
    "\Process(reciever)\IO Data Bytes/sec",
    "\Process(reciever)\Private Bytes",
    "\Process(msedge)\% Processor Time",
    "\Process(msedge)\IO Data Bytes/sec",
    "\Process(msedge)\Private Bytes",
    "\Process(MsMpEng)\% Processor Time",
    "\Process(MsMpEng)\IO Data Bytes/sec",
    "\Process(MsMpEng)\Private Bytes",
    "\Process(ndOffice)\% Processor Time",
    "\Process(ndOffice)\IO Data Bytes/sec",
    "\Process(ndOffice)\Private Bytes",
    "\Process(NetDocuments.ndMail.Application)\% Processor Time",
    "\Process(NetDocuments.ndMail.Application)\IO Data Bytes/sec",
    "\Process(NetDocuments.ndMail.Application)\Private Bytes",
    "\Process(OneDrive)\% Processor Time",
    "\Process(OneDrive)\IO Data Bytes/sec",
    "\Process(OneDrive)\Private Bytes",
    "\Process(OUTLOOK)\% Processor Time",
    "\Process(OUTLOOK)\IO Data Bytes/sec",
    "\Process(OUTLOOK)\Private Bytes",
    "\Process(PanGPS)\% Processor Time",
    "\Process(PanGPS)\IO Data Bytes/sec",
    "\Process(PanGPS)\Private Bytes",
    "\Process(PowerPDF)\% Processor Time",
    "\Process(PowerPDF)\IO Data Bytes/sec",
    "\Process(PowerPDF)\Private Bytes",
    "\Process(jabra-direct)\% Processor Time",
    "\Process(jabra-direct)\IO Data Bytes/sec",
    "\Process(jabra-direct)\Private Bytes",
    "\Process(Teams)\% Processor Time",
    "\Process(Teams)\IO Data Bytes/sec",
    "\Process(Teams)\Private Bytes",
    "\Process(WINWORD)\% Processor Time",
    "\Process(WINWORD)\IO Data Bytes/sec",
    "\Process(WINWORD)\Private Bytes",
    "\Memory\Available MBytes",
    "\Memory\Page Faults/sec",
    "\Memory\Pages/sec",
    "\Network Adapter(*)\Bytes Total/sec",
    "\PhysicalDisk(_Total)\% Idle Time",
    "\PhysicalDisk(_Total)\Avg. Disk Bytes/Read",
    "\PhysicalDisk(_Total)\Avg. Disk Bytes/Write",
    "\Processor(_Total)\% Privileged Time",
    "\Processor(_Total)\% Processor Time",
    "\Processor(_Total)\% User Time",
    "\Thermal Zone Information(\_SB._SAN.TZ01)\High Precision Temperature",
    "\Thermal Zone Information(\_SB._SAN.TZ01)\Temperature",
    "\Process(EXCEL)\% Processor Time",
    "\Process(EXCEL)\Private Bytes",
    "\Process(EXCEL)\IO Data Bytes/sec",
    "\Process(POWERPNT)\% Processor Time",
    "\Process(POWERPNT)\Private Bytes",
    "\Process(POWERPNT)\IO Data Bytes/sec"
)

# Generate XML configuration
$xmlFilePath = "$basePath\PerfMon-2025.xml"
Write-Output "Generating XML configuration: $xmlFilePath"
$xmlContent = @"
<?xml version="1.0"?>
<DataCollectorSet>
    <Name>$dataCollectorSetName</Name>
    <RootPath>$basePath</RootPath>
    <Duration>$duration</Duration>
    <SampleInterval>$samplingInterval</SampleInterval>
    <Counters>
        $(ForEach ($counter in $counters) { "<Counter>$counter</Counter>" })
    </Counters>
    <LogFileFormat>blg</LogFileFormat>
    <OutputLocation>$blgFilePath</OutputLocation>
</DataCollectorSet>
"@
$xmlContent | Out-File -FilePath $xmlFilePath -Encoding utf-8 -Force

# Create and start Data Collector Set using XML
Write-Output "Importing Data Collector Set from XML..."
$importCommand = "logman import -n $dataCollectorSetName -xml $xmlFilePath"
Invoke-Expression $importCommand

if ($LASTEXITCODE -ne 0) {
    Write-Error "Error: Failed to import Data Collector Set."
    exit 1
}

Write-Output "Starting Data Collector Set..."
$startCommand = "logman start $dataCollectorSetName"
Invoke-Expression $startCommand

if ($LASTEXITCODE -ne 0) {
    Write-Error "Error: Failed to start Data Collector Set."
    exit 1
}

Write-Output "Data Collector Set started successfully. Collecting data for $duration seconds..."

# Wait for collection to complete
Start-Sleep -Seconds $duration

# Stop Data Collector Set
Write-Output "Stopping Data Collector Set..."
$stopCommand = "logman stop -n PerfMon-2025"
Invoke-Expression $stopCommand

#############################################################################################################
### Just neeed to export BLG-CSV to complete!
# Export BLG to CSV
Write-Output "Exporting BLG to CSV: $csvFilePath"
$exportCommand = "relog `"$blgFilePath`" -f CSV -o `"$csvFilePath`""
Invoke-Expression $exportCommand

if ($LASTEXITCODE -ne 0) {
    Write-Error "Error: Failed to export BLG to CSV."
    exit 1
}

Write-Output "Data collection and export completed successfully. BLG: $blgFilePath, CSV: $csvFilePath"




















###############################################################
### XML - Minus all the counters
<?xml version="1.0" encoding="UTF-16"?>
<DataCollectorSet>
	<Status>0</Status>
	<Duration>21600</Duration>
	<Description>
	</Description>
	<DescriptionUnresolved>
	</DescriptionUnresolved>
	<DisplayName>
	</DisplayName>
	<DisplayNameUnresolved>
	</DisplayNameUnresolved>
	<SchedulesEnabled>-1</SchedulesEnabled>
	<LatestOutputLocation>C:\PerfLogs\Admin\JL-PerfMon\LT4036_20230419-000009</LatestOutputLocation>
	<Name>JL-Process-HardwareAnalysis</Name>
	<OutputLocation>C:\PerfLogs\Admin\JL-Process-HardwareAnalysis\LT4122_20230515-000010</OutputLocation>
	<RootPath>%systemdrive%\PerfLogs\Admin\JL-Process-HardwareAnalysis</RootPath>
	<Segment>0</Segment>
	<SegmentMaxDuration>0</SegmentMaxDuration>
	<SegmentMaxSize>0</SegmentMaxSize>
	<SerialNumber>10</SerialNumber>
	<Server>
	</Server>
	<Subdirectory>
	</Subdirectory>
	<SubdirectoryFormat>3</SubdirectoryFormat>
	<SubdirectoryFormatPattern>yyyyMMdd\-NNNNNN</SubdirectoryFormatPattern>
	<Task>
	</Task>
	<TaskRunAsSelf>0</TaskRunAsSelf>
	<TaskArguments>
	</TaskArguments>
	<TaskUserTextArguments>
	</TaskUserTextArguments>
	<UserAccount>SYSTEM</UserAccount>
	<Security>O:BAG:DUD:AI(A;;FA;;;SY)(A;;FA;;;BA)(A;;0x1200a9;;;LU)(A;;0x1301ff;;;S-1-5-80-2661322625-712705077-2999183737-3043590567-590698655)(A;ID;0x1f019f;;;BA)(A;ID;0x1f019f;;;SY)(A;ID;FR;;;AU)(A;ID;FR;;;LS)(A;ID;FR;;;NS)(A;ID;FA;;;BA)</Security>
	<StopOnCompletion>0</StopOnCompletion>
	<PerformanceCounterDataCollector>
		<DataCollectorType>0</DataCollectorType>
		<Name>DataCollector01</Name>
		<FileName>DataCollector01</FileName>
		<FileNameFormat>1</FileNameFormat>
		<FileNameFormatPattern>
		</FileNameFormatPattern>
		<LogAppend>0</LogAppend>
		<LogCircular>0</LogCircular>
		<LogOverwrite>0</LogOverwrite>
		<LatestOutputLocation>C:\PerfLogs\Admin\JL-PerfMon\LT4036_20230419-000009\DataCollector01.blg</LatestOutputLocation>
		<DataSourceName>
		</DataSourceName>
		<SampleInterval>30</SampleInterval>
		<SegmentMaxRecords>0</SegmentMaxRecords>
		<LogFileFormat>3</LogFileFormat>
</PerformanceCounterDataCollector>
<DataManager>
    <Enabled>0</Enabled>
    <CheckBeforeRunning>0</CheckBeforeRunning>
    <MinFreeDisk>0</MinFreeDisk>
    <MaxSize>0</MaxSize>
    <MaxFolderCount>0</MaxFolderCount>
    <ResourcePolicy>0</ResourcePolicy>
    <ReportFileName>report.html</ReportFileName>
    <RuleTargetFileName>report.xml</RuleTargetFileName>
    <EventsFileName>
    </EventsFileName>
</DataManager>
</DataCollectorSet>

"@
### Botttom of XML
########################################