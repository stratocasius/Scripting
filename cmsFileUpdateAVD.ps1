### Aderant cms.ini file update - 06/26/2025
# Track script start time (before anything else happens)
$global:ScriptStartTime = Get-Date
$LogFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Aderant-cmsFileUpdate-Transcript.log"
# Ensure the log directory exists
$LogDir = Split-Path -Path $LogFile -Parent
if (-not (Test-Path -Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}
# Start logging
Start-Transcript -Path $LogFile

# Define file path
$cmsPath = "C:\Program Files\Aderant\BIN\cms.ini"

# Exit if file not found
if (-not (Test-Path $cmsPath)) {
    Write-Output "cms.ini file not found. Exiting."
    exit 0
}

# Read the content as raw text and normalize line endings
$originalContent = (Get-Content $cmsPath -Raw) -replace "`r`n", "`n"

# Define the original block (normalized to `\n`)
$originalBlock = @"
[default connection]
connection=ADR_LIVE

[ADR_LIVE]
vendor=1
location=ADRLIVEDB
database=ADR_LIVE	
forcemanuallogin=0

[FADR_LIVE]
vendor=1
location=ADRLIVEDB
database=ADR_LIVE 	
forcemanuallogin=1

[CMSSQL]
IgnoreOptimizerFlag=1
;PacketSize=512
;LogToWindow=1
;LogToFile=1
;LogFile=d:\becky.log
;DeleteLogFile=0
;LogSQLStatementsOnly=0

[Security]
--ManageHtmlHelpSecurity=1

[Importer]
MainIndex=\\adrlivefiles\aderant\IMPORTER\07509.NDX
ActivityLoggingPlans=\\adrlivefiles\aderant\IMPORTER\ACTIVITY.INI
PerformanceLoggingPlans=\\adrlivefiles\aderant\IMPORTER\PERFORM.INI
DefaultConfiguration=\\AdrLiveFiles\Aderant\IMPORTER\default.cfg

[Personal]
KeypadEnterAsTab=1

[MarkText Options]
MarkDate=1
MarkNumeric=1
MarkChar=1
MarkCharLen=80

[GRS]
Filename=U:\report.rv
FileFormat=V
DestPrinter=0
DestFile=0
ViewOutput=1
AutoOverwrite=1
TCPIPPrinting=1

[Speller]
CustomSpellcheckDictionary=U:\CUSTOM.dic

[BOS Printers]
PrinterName=

[Custom Colors]
ColorA=ffffff
ColorB=ffffff
ColorC=ffffff
ColorD=ffffff
ColorE=ffffff
ColorF=ffffff
ColorG=ffffff
ColorH=ffffff
ColorI=ffffff
ColorJ=ffffff
ColorK=ffffff
ColorL=ffffff
ColorM=ffffff
ColorN=ffffff
ColorO=ffffff
ColorP=ffffff

[EIPATH] 
AppPath=\\JLERP8-APS-E01\ExpertImaging\Apps\
"@ -replace "`r`n", "`n"

# Define the updated block (normalized to `\n`)
$updatedBlock = @"
[default connection]
connection=ADR_LIVE

[ADR_LIVE]
vendor=1
location=ADRLIVEDB
database=ADR_LIVE	
forcemanuallogin=0

[FADR_LIVE]
vendor=1
location=ADRLIVEDB
database=ADR_LIVE 	
forcemanuallogin=1

[CMSSQL]
;IgnoreOptimizerFlag=1
;PacketSize=512
;LogToWindow=1
;LogToFile=1
;LogFile=d:\becky.log
;DeleteLogFile=0
;LogSQLStatementsOnly=0

[Security]
--ManageHtmlHelpSecurity=1

[Importer]
MainIndex=\\vm-nasuni-01\erpdata\adrsandboxfiles\aderant\IMPORTER\07509.NDX
ActivityLoggingPlans=\\vm-nasuni-01\erpdata\adrsandboxfiles\aderant\IMPORTER\ACTIVITY.INI
PerformanceLoggingPlans=\\vm-nasuni-01\erpdata\adrsandboxfiles\aderant\IMPORTER\PERFORM.INI
DefaultConfiguration=\\vm-nasuni-01\erpdata\adrsandboxfiles\aderant\IMPORTER\default.cfg

[Personal]
KeypadEnterAsTab=1

[MarkText Options]
MarkDate=1
MarkNumeric=1
MarkChar=1
MarkCharLen=80

[GRS]
Filename=U:\report.rv
FileFormat=V
DestPrinter=0
DestFile=0
ViewOutput=1
AutoOverwrite=1
TCPIPPrinting=1

[Speller]
CustomSpellcheckDictionary=U:\CUSTOM.dic

[BOS Printers]
PrinterName=

[Custom Colors]
ColorA=ffffff
ColorB=ffffff
ColorC=ffffff
ColorD=ffffff
ColorE=ffffff
ColorF=ffffff
ColorG=ffffff
ColorH=ffffff
ColorI=ffffff
ColorJ=ffffff
ColorK=ffffff
ColorL=ffffff
ColorM=ffffff
ColorN=ffffff
ColorO=ffffff
ColorP=ffffff

[EIPATH] 
AppPath=\\JLERP8-APS-E01\ExpertImaging\Apps\
"@ -replace "`r`n", "`n"

# Check if already updated
if ($originalContent.Contains($updatedBlock)) {
    Write-Output "cms.ini already updated. Exiting."
    exit 0
}

# Check if the original block exists
if ($originalContent.Contains($originalBlock)) {
    # Backup original
    $backupPath = "$cmsPath.bak"
    Copy-Item -Path $cmsPath -Destination $backupPath -Force

    # Perform replacement
    $newContent = $originalContent.Replace($originalBlock, $updatedBlock)

    # Restore Windows line endings
    $newContent = $newContent -replace "`n", "`r`n"

    # Write changes
    Set-Content -Path $cmsPath -Value $newContent -Encoding UTF8 -Force
    Write-Output "cms.ini successfully updated. Backup saved as cms.ini.bak"
} else {
    Write-Output "Original CMS.ini block not found. No changes made."
}
# Calculate duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("Aderant CMS file update total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
Stop-Transcript