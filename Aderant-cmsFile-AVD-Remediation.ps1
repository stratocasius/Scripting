### Aderant CMS File Remediation - 06/26/2025 
### Remediation to cms.ini file that needs [IMPORTER] block edited.
$cmsPath = "C:\Program Files\Aderant\BIN\cms.ini"
$backupPath = "$cmsPath.bak"

# Check if cms.ini exists
if (-not (Test-Path $cmsPath)) {
    Write-Output "cms.ini file not found. Nothing to remediate."
    exit 0
}

# Backup the original file
try {
    Copy-Item -Path $cmsPath -Destination $backupPath -Force
    Write-Output "Backup created at $backupPath"
} catch {
    Write-Output "Failed to create backup: $_"
    exit 1
}

# Read and normalize content
$content = (Get-Content $cmsPath -Raw) -replace "`r`n", "`n"

# Define the original block
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

# Define the updated block
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

# Replace block if original is present
if ($content.Contains($originalBlock)) {
    $newContent = $content.Replace($originalBlock, $updatedBlock)
    $newContent = $newContent -replace "`n", "`r`n"

    try {
        Set-Content -Path $cmsPath -Value $newContent -Encoding UTF8 -Force
        Write-Output "cms.ini updated successfully."
    } catch {
        Write-Output "Error writing cms.ini: $_"
        exit 1
    }
}