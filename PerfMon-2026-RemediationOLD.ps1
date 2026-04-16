### 02/26/2026 - PerfMon for Adobe Acrobat scope.
### Modified:
###  - Writes XML + outputs under:
###      C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PerfMonitor
###  - If PerfMonitor exists, archive it as PerfMonitor-MMddyyyy (or -1, -2, etc)
###  - Creates JL-Process-Adobe-HardwareAnalysis.xml in the same PerfMonitor folder
###  - Imports + starts collector JL-Process-HW-Stats4
###  - Attempts BLG -> CSV export once BLG exists

# ============================================================
# Pre-Run Cleanup – Date-Stamped Archive of PerfMonitor Folder
# ============================================================

$basePath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$perfRoot = Join-Path $basePath "PerfMonitor"

# Stop collector if running (prevents BLG lock issues)
try {
    logman stop "JL-Process-HW-Stats4" -ets 2>$null | Out-Null
} catch {}

# Optional: delete existing collector definition so imports are repeatable
try {
    logman delete "JL-Process-HW-Stats4" 2>$null | Out-Null
} catch {}

if (Test-Path $perfRoot) {
    Write-Output "Existing PerfMonitor folder detected."

    $dateStamp = Get-Date -Format "MMddyyyy"
    $archiveLeaf = "PerfMonitor-$dateStamp"
    $archivePath = Join-Path $basePath $archiveLeaf

    $counter = 1
    while (Test-Path $archivePath) {
        $archiveLeaf = "PerfMonitor-$dateStamp-$counter"
        $archivePath = Join-Path $basePath $archiveLeaf
        $counter++
    }

    Write-Output "Renaming PerfMonitor to $archiveLeaf..."
    Rename-Item -Path $perfRoot -NewName $archiveLeaf -ErrorAction Stop
    Start-Sleep 2
}

# Create fresh PerfMonitor folder
Write-Output "Creating fresh PerfMonitor folder..."
New-Item -Path $perfRoot -ItemType Directory -Force | Out-Null

# Create subfolders referenced by the XML (helps avoid logman quirks)
New-Item -Path (Join-Path $perfRoot "Latest") -ItemType Directory -Force | Out-Null
New-Item -Path (Join-Path $perfRoot "Output") -ItemType Directory -Force | Out-Null

# ============================================================
# Build XML and write to PerfMonitor folder
# ============================================================

$xmlPath = Join-Path $perfRoot "JL-Process-Adobe-HardwareAnalysis.xml"

$collectorSetXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<DataCollectorSet>
	<Status>0</Status>
	<Duration>21600</Duration>
	<Description></Description>
	<DescriptionUnresolved></DescriptionUnresolved>
	<DisplayName></DisplayName>
	<DisplayNameUnresolved></DisplayNameUnresolved>
	<SchedulesEnabled>-1</SchedulesEnabled>
	<LatestOutputLocation>$perfRoot\Latest</LatestOutputLocation>
	<Name>JL-Process-HardwareAnalysis</Name>
	<OutputLocation>$perfRoot\Output</OutputLocation>
	<RootPath>$perfRoot</RootPath>
	<Segment>0</Segment>
	<SegmentMaxDuration>0</SegmentMaxDuration>
	<SegmentMaxSize>0</SegmentMaxSize>
	<SerialNumber>10</SerialNumber>
	<Server></Server>
	<Subdirectory></Subdirectory>
	<SubdirectoryFormat>3</SubdirectoryFormat>
	<SubdirectoryFormatPattern>yyyyMMdd\-NNNNNN</SubdirectoryFormatPattern>
	<Task></Task>
	<TaskRunAsSelf>0</TaskRunAsSelf>
	<TaskArguments></TaskArguments>
	<TaskUserTextArguments></TaskUserTextArguments>
	<UserAccount>SYSTEM</UserAccount>
	<StopOnCompletion>0</StopOnCompletion>
	<PerformanceCounterDataCollector>
		<DataCollectorType>0</DataCollectorType>
		<Name>DataCollector01</Name>
		<FileName>DataCollector01</FileName>
		<FileNameFormat>1</FileNameFormat>
		<FileNameFormatPattern></FileNameFormatPattern>
		<LogAppend>0</LogAppend>
		<LogCircular>0</LogCircular>
		<LogOverwrite>0</LogOverwrite>
		<LatestOutputLocation>$perfRoot\Latest\DataCollector01.blg</LatestOutputLocation>
		<DataSourceName></DataSourceName>
		<SampleInterval>30</SampleInterval>
		<SegmentMaxRecords>0</SegmentMaxRecords>
		<LogFileFormat>3</LogFileFormat>
		<Counter>\Process(ACC)\% Processor Time</Counter>
		<Counter>\Process(ACC)\IO Data Bytes/sec</Counter>
		<Counter>\Process(ACC)\Private Bytes</Counter>
		<Counter>\Process(Acrobat)\% Processor Time</Counter>
		<Counter>\Process(Acrobat)\IO Data Bytes/sec</Counter>
		<Counter>\Process(Acrobat)\Private Bytes</Counter>
		<Counter>\Process(AcroCEF)\% Processor Time</Counter>
		<Counter>\Process(AcroCEF)\IO Data Bytes/sec</Counter>
		<Counter>\Process(AcroCEF)\Private Bytes</Counter>
		<Counter>\Process(Adobe Deskop Service)\% Processor Time</Counter>
		<Counter>\Process(Adobe Deskop Service)\IO Data Bytes/sec</Counter>
		<Counter>\Process(Adobe Deskop Service)\Private Bytes</Counter>
		<Counter>\Process(AdobeCollabSync)\% Processor Time</Counter>
		<Counter>\Process(AdobeCollabSync)\IO Data Bytes/sec</Counter>
		<Counter>\Process(AdobeCollabSync)\Private Bytes</Counter>
		<Counter>\Process(AdobeIPCBroker)\% Processor Time</Counter>
		<Counter>\Process(AdobeIPCBroker)\IO Data Bytes/sec</Counter>
		<Counter>\Process(AdobeIPCBroker)\Private Bytes</Counter>
		<Counter>\Process(AdobeNotificationClient)\% Processor Time</Counter>
		<Counter>\Process(AdobeNotificationClient)\IO Data Bytes/sec</Counter>
		<Counter>\Process(AdobeNotificationClient)\Private Bytes</Counter>
		<Counter>\Process(AdobeUpdateService)\% Processor Time</Counter>
		<Counter>\Process(AdobeUpdateService)\IO Data Bytes/sec</Counter>
		<Counter>\Process(AdobeUpdateService)\Private Bytes</Counter>
		<Counter>\Process(CCLibrary)\% Processor Time</Counter>
		<Counter>\Process(CCLibrary)\IO Data Bytes/sec</Counter>
		<Counter>\Process(CCLibrary)\Private Bytes</Counter>
		<Counter>\Process(CCXProcess)\% Processor Time</Counter>
		<Counter>\Process(CCXProcess)\IO Data Bytes/sec</Counter>
		<Counter>\Process(CCXProcess)\Private Bytes</Counter>
		<Counter>\Process(CoreSync)\% Processor Time</Counter>
		<Counter>\Process(CoreSync)\IO Data Bytes/sec</Counter>
		<Counter>\Process(CoreSync)\Private Bytes</Counter>
		<Counter>\Process(Creative Cloud Helper)\% Processor Time</Counter>
		<Counter>\Process(Creative Cloud Helper)\IO Data Bytes/sec</Counter>
		<Counter>\Process(Creative Cloud Helper)\Private Bytes</Counter>
		<Counter>\Process(Creative Cloud UI Helper)\% Processor Time</Counter>
		<Counter>\Process(Creative Cloud UI Helper)\IO Data Bytes/sec</Counter>
		<Counter>\Process(Creative Cloud UI Helper)\Private Bytes</Counter>
		<Counter>\Process(Creative Cloud)\% Processor Time</Counter>
		<Counter>\Process(Creative Cloud)\IO Data Bytes/sec</Counter>
		<Counter>\Process(Creative Cloud)\Private Bytes</Counter>
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
		<Counter>\Process(PANGPS)\% Processor Time</Counter>
		<Counter>\Process(PANGPS)\IO Data Bytes/sec</Counter>
		<Counter>\Process(PANGPS)\Private Bytes</Counter>
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

# Write XML into PerfMonitor folder
$collectorSetXml | Out-File -FilePath $xmlPath -Encoding Unicode -Force
Start-Sleep 2

# ============================================================
# Import and Start Collector
# ============================================================

$logmanCommand = "logman import -n JL-Process-HW-Stats4 -xml `"$xmlPath`""
Invoke-Expression $logmanCommand

$logmanCommand = "logman start JL-Process-HW-Stats4"
Invoke-Expression $logmanCommand

# ============================================================
# Optional: Attempt BLG -> CSV export (best-effort)
# ============================================================

try {
    # Logman typically creates a dated subfolder under Output due to SubdirectoryFormatPattern
    $q = logman query "JL-Process-HW-Stats4" 2>$null
    $outLine = ($q | Select-String -Pattern "Output Location" -SimpleMatch | Select-Object -First 1).Line
    $outPath = $null

    if ($outLine -match "Output Location:\s*(.+)\s*$") {
        $outPath = $Matches[1].Trim()
    }

    if ($outPath -and (Test-Path $outPath)) {
        $blgPath = Join-Path $outPath "DataCollector01.blg"
        $csvPath = Join-Path $outPath "DataCollector01.csv"

        if (Test-Path $blgPath) {
            $logmanExport = "relog `"$blgPath`" -f CSV -o `"$csvPath`""
            Invoke-Expression $logmanExport
        } else {
            Write-Output "BLG not present yet at: $blgPath (export will be skipped on this run)."
        }
    } else {
        Write-Output "Could not determine/validate Output Location from logman query."
    }
}
catch {
    Write-Output "Best-effort relog export failed: $($_.Exception.Message)"
}