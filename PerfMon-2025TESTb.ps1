### 12/02/2024 - Updated processes and analysis of key hardware components - panGPS replaced Netskope.
### Relocated logging to C:\programdata\Microsoft\IntuneManagementExtension\Logs\PerfMonLogs
$collectorSetXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<DataCollectorSet>
	<Status>0</Status>
	<Duration>900</Duration>
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
    <Security>O:BAG:DUD:AI(A;;FA;;;SY)(A;;FA;;;BA)</Security>
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
		<Counter>\Process(chrome)\% Processor Time</Counter>
		<Counter>\Process(chrome)\IO Data Bytes/sec</Counter>
		<Counter>\Process(chrome)\Private Bytes</Counter>
		<Counter>\Process(IntappTime)\% Processor Time</Counter>
		<Counter>\Process(IntappTime)\IO Data Bytes/sec</Counter>
		<Counter>\Process(IntappTime)\Private Bytes</Counter>
		<Counter>\Process(IntappTimeDesktopExtension)\% Processor Time</Counter>
		<Counter>\Process(IntappTimeDesktopExtension)\IO Data Bytes/sec</Counter>
		<Counter>\Process(IntappTimeDesktopExtension)\Private Bytes</Counter>
		<Counter>\Process(reciever)\% Processor Time</Counter>
		<Counter>\Process(reciever)\IO Data Bytes/sec</Counter>
		<Counter>\Process(reciever)\Private Bytes</Counter>
		<Counter>\Process(msedge)\% Processor Time</Counter>
		<Counter>\Process(msedge)\IO Data Bytes/sec</Counter>
		<Counter>\Process(msedge)\Private Bytes</Counter>
		<Counter>\Process(MsMpEng)\% Processor Time</Counter>
		<Counter>\Process(MsMpEng)\IO Data Bytes/sec</Counter>
		<Counter>\Process(MsMpEng)\Private Bytes</Counter>
		<Counter>\Process(ndOffice)\% Processor Time</Counter>
		<Counter>\Process(ndOffice)\IO Data Bytes/sec</Counter>
		<Counter>\Process(ndOffice)\Private Bytes</Counter>
		<Counter>\Process(NetDocuments.ndMail.Application)\% Processor Time</Counter>
		<Counter>\Process(NetDocuments.ndMail.Application)\IO Data Bytes/sec</Counter>
		<Counter>\Process(NetDocuments.ndMail.Application)\Private Bytes</Counter>
		<Counter>\Process(OneDrive)\% Processor Time</Counter>
		<Counter>\Process(OneDrive)\IO Data Bytes/sec</Counter>
		<Counter>\Process(OneDrive)\Private Bytes</Counter>
		<Counter>\Process(OUTLOOK)\% Processor Time</Counter>
		<Counter>\Process(OUTLOOK)\IO Data Bytes/sec</Counter>
        <Counter>\Process(OUTLOOK)\Private Bytes</Counter>  
        <Counter>\Process(panGPS)\% Processor Time</Counter>
		<Counter>\Process(panGPS)\IO Data Bytes/sec</Counter>
		<Counter>\Process(panGPS)\Private Bytes</Counter>
		<Counter>\Process(PowerPDF)\% Processor Time</Counter>
		<Counter>\Process(PowerPDF)\IO Data Bytes/sec</Counter>
		<Counter>\Process(PowerPDF)\Private Bytes</Counter>
		<Counter>\Process(jabra-direct)\% Processor Time</Counter>
		<Counter>\Process(jabra-direct)\IO Data Bytes/sec</Counter>
		<Counter>\Process(jabra-direct)\Private Bytes</Counter>
		<Counter>\Process(Teams)\% Processor Time</Counter>
		<Counter>\Process(Teams)\IO Data Bytes/sec</Counter>
		<Counter>\Process(Teams)\Private Bytes</Counter>
		<Counter>\Process(WINWORD)\% Processor Time</Counter>
		<Counter>\Process(WINWORD)\IO Data Bytes/sec</Counter>
		<Counter>\Process(WINWORD)\Private Bytes</Counter>
		<Counter>\Memory\Available MBytes</Counter>
		<Counter>\Memory\Page Faults/sec</Counter>
		<Counter>\Memory\Pages/sec</Counter>
		<Counter>\Network Adapter(*)\Bytes Total/sec</Counter>
		<Counter>\PhysicalDisk(_Total)\% Idle Time</Counter>
		<Counter>\PhysicalDisk(_Total)\Avg. Disk Bytes/Read</Counter>
		<Counter>\PhysicalDisk(_Total)\Avg. Disk Bytes/Write</Counter>
		<Counter>\Processor(_Total)\% Privileged Time</Counter>
		<Counter>\Processor(_Total)\% Processor Time</Counter>
		<Counter>\Processor(_Total)\% User Time</Counter>
		<Counter>\Thermal Zone Information(\_SB._SAN.TZ01)\High Precision Temperature</Counter>
		<Counter>\Thermal Zone Information(\_SB._SAN.TZ01)\Temperature</Counter>
		<Counter>\Process(EXCEL)\% Processor Time</Counter>
		<Counter>\Process(EXCEL)\Private Bytes</Counter>
		<Counter>\Process(EXCEL)\IO Data Bytes/sec</Counter>
		<Counter>\Process(POWERPNT)\% Processor Time</Counter>
		<Counter>\Process(POWERPNT)\Private Bytes</Counter>
		<Counter>\Process(POWERPNT)\IO Data Bytes/sec</Counter>
		<CounterDisplayName>\Process(chrome)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(chrome)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(chrome)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(IntappTime)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(IntappTime)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(IntappTime)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(IntappTimeDesktopExtension)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(IntappTimeDesktopExtension)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(IntappTimeDesktopExtension)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(ir_agent)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(ir_agent)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(ir_agent)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(msedge)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(msedge)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(msedge)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(MsMpEng)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(MsMpEng)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(MsMpEng)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(ndOffice)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(ndOffice)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(ndOffice)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(NetDocuments.ndMail.Application)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(NetDocuments.ndMail.Application)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(NetDocuments.ndMail.Application)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(OneDrive)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(OneDrive)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(OneDrive)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(OUTLOOK)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(OUTLOOK)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(OUTLOOK)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(PowerPDF)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(PowerPDF)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(PowerPDF)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(panGPS)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(panGPS)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(panGPS)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(Teams)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(Teams)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(Teams)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(WINWORD)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(WINWORD)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(WINWORD)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Memory\Available MBytes</CounterDisplayName>
		<CounterDisplayName>\Memory\Page Faults/sec</CounterDisplayName>
		<CounterDisplayName>\Memory\Pages/sec</CounterDisplayName>
		<CounterDisplayName>\Network Adapter(*)\Bytes Total/sec</CounterDisplayName>
		<CounterDisplayName>\PhysicalDisk(_Total)\% Idle Time</CounterDisplayName>
		<CounterDisplayName>\PhysicalDisk(_Total)\Avg. Disk Bytes/Read</CounterDisplayName>
		<CounterDisplayName>\PhysicalDisk(_Total)\Avg. Disk Bytes/Write</CounterDisplayName>
		<CounterDisplayName>\Processor(_Total)\% Privileged Time</CounterDisplayName>
		<CounterDisplayName>\Processor(_Total)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Processor(_Total)\% User Time</CounterDisplayName>
		<CounterDisplayName>\Thermal Zone Information(\_SB._SAN.TZ01)\High Precision Temperature</CounterDisplayName>
		<CounterDisplayName>\Thermal Zone Information(\_SB._SAN.TZ01)\Temperature</CounterDisplayName>
		<CounterDisplayName>\Process(EXCEL)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(EXCEL)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(EXCEL)\IO Data Bytes/sec</CounterDisplayName>
		<CounterDisplayName>\Process(POWERPNT)\% Processor Time</CounterDisplayName>
		<CounterDisplayName>\Process(POWERPNT)\Private Bytes</CounterDisplayName>
		<CounterDisplayName>\Process(POWERPNT)\IO Data Bytes/sec</CounterDisplayName>
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

$collectorSetXml | Out-File -FilePath "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PerfMonLogs\JL-Process-HardwareAnalysis.xml"
start-sleep 5 -Verbose
# Import the data collector set from the JL-Process-HardwareAnalysis.xml file and save it as name JL-Process-HW-Stats
$logmanCommand = "logman import -n JL-Process-HW-Stats -xml C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PerfMonLogs\JL-Process-HardwareAnalysis.xml"
Invoke-Expression $logmanCommand -ErrorAction SilentlyContinue

# Start the data collection process using the JL-Process-HW-Stats data collector set
$logmanCommand = "logman start JL-Process-HW-Stats"
Invoke-Expression $logmanCommand

# Export the data to a CSV locally at C:\jltools\
$logmanExport = "relog DataCollector01.blg -f CSV -o C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PerfMonLogs\DataCollector01.csv"
Invoke-Expression $logmanExport