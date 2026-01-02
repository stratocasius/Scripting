# Detection Script: Looks for the original block; if found, triggers remediation via exit 1

$cmsPath = "C:\Program Files\Aderant\BIN\cms.ini"

if (-not (Test-Path $cmsPath)) {
    Write-Output "cms.ini not found. Assuming no remediation needed."
    exit 0
}

$content = (Get-Content $cmsPath -Raw) -replace "`r`n", "`n"

# Corrected here-string: No characters after @" and closes on its own line
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

if ($content.Contains($originalBlock)) {
    Write-Output "Original block found. Remediation required."
    exit 1
}
Else{
    Write-Output "No remediation needed."
    exit 0
}