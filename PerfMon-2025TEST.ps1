### Deployable Script for Data Collector Set
### Creates and executes a Data Collector Set based on the provided XML

# Variables
$basePath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\JLPerfMon-2025"
$xmlFilePath = "$basePath\JL-2025.xml"
$dataCollectorSetName = "JL-2025.xml"
$outputLocation = "$basePath\0F3C6RM24253MR_20250110-000001"

# Ensure required directories exist
Write-Output "Ensuring required directories exist..."
New-Item -Path $basePath -ItemType Directory -Force | Out-Null

# Define the Data Collector Set XML
$collectorSetXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<DataCollectorSet>
    <Status>0</Status>
    <Duration>21600</Duration>
    <Description></Description>
    <DescriptionUnresolved></DescriptionUnresolved>
    <DisplayName></DisplayName>
    <DisplayNameUnresolved></DisplayNameUnresolved>
    <SchedulesEnabled>-1</SchedulesEnabled>
    <LatestOutputLocation></LatestOutputLocation>
    <Name>$dataCollectorSetName</Name>
    <OutputLocation>$outputLocation</OutputLocation>
    <RootPath>$basePath</RootPath>
    <Segment>0</Segment>
    <SegmentMaxDuration>0</SegmentMaxDuration>
    <SegmentMaxSize>0</SegmentMaxSize>
    <SerialNumber>1</SerialNumber>
    <Server></Server>
    <Subdirectory></Subdirectory>
    <SubdirectoryFormat>3</SubdirectoryFormat>
    <SubdirectoryFormatPattern>yyyyMMdd\-NNNNNN</SubdirectoryFormatPattern>
    <Task></Task>
    <TaskRunAsSelf>0</TaskRunAsSelf>
    <TaskArguments></TaskArguments>
    <TaskUserTextArguments></TaskUserTextArguments>
    <UserAccount>SYSTEM</UserAccount>
    <Security>O:BAG:S-1-12-1-3223428461-1210829702-12356014-3239727644D:AI(A;;FA;;;SY)(A;;FA;;;BA)(A;;0x1200a9;;;LU)(A;;0x1301ff;;;S-1-5-80-2661322625-712705077-2999183737-3043590567-590698655)(A;ID;0x1f019f;;;BA)(A;ID;0x1f019f;;;SY)(A;ID;FR;;;AU)(A;ID;FR;;;LS)(A;ID;FR;;;NS)(A;ID;FA;;;BA)</Security>
    <StopOnCompletion>-1</StopOnCompletion>
    <PerformanceCounterDataCollector>
        <DataCollectorType>0</DataCollectorType>
        <Name>DataCollector01</Name>
        <FileName>DataCollector01</FileName>
        <FileNameFormat>0</FileNameFormat>
        <FileNameFormatPattern></FileNameFormatPattern>
        <LogAppend>0</LogAppend>
        <LogCircular>0</LogCircular>
        <LogOverwrite>0</LogOverwrite>
        <LatestOutputLocation></LatestOutputLocation>
        <DataSourceName></DataSourceName>
        <SampleInterval>30</SampleInterval>
        <SegmentMaxRecords>0</SegmentMaxRecords>
        <LogFileFormat>3</LogFileFormat>
        <!-- Add counters -->
        <Counter>\Process(chrome)\% Processor Time</Counter>
        <Counter>\Process(chrome)\IO Data Bytes/sec</Counter>
        <Counter>\Process(chrome)\Private Bytes</Counter>
        <Counter>\Memory\Available MBytes</Counter>
        <Counter>\Processor(_Total)\% Processor Time</Counter>
        <Counter>\Processor(_Total)\% User Time</Counter>
        <Counter>\Processor(_Total)\% Privileged Time</Counter>
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
        <EventsFileName></EventsFileName>
    </DataManager>
</DataCollectorSet>
"@

# Save the XML to the file
Write-Output "Saving Data Collector Set XML..."
$collectorSetXml | Out-File -FilePath $xmlFilePath -Encoding UTF8 -Force

# Import the Data Collector Set
Write-Output "Importing Data Collector Set..."
$importCommand = "logman import -n $dataCollectorSetName -xml $xmlFilePath"
Invoke-Expression $importCommand

if ($LASTEXITCODE -ne 0) {
    Write-Error "Error: Failed to import Data Collector Set."
    exit 1
} else {
    Write-Output "Data Collector Set imported successfully."
}

# Start the Data Collector Set
Write-Output "Starting Data Collector Set..."
$startCommand = "logman start $dataCollectorSetName"
Invoke-Expression $startCommand