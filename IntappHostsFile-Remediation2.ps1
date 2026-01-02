### Intapp Host File Remediation - Remediation Script - 03/25/2025
### Remediates any deviation in the hosts.cfg file for Intapp Time.
### Establish logging
$logFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\IntappTimeHostsRemediation-Remediation-Transcript.log"
Start-Transcript -Path $logFilePath
# Define the path to the host.cfg file
# Path to host.cfg
$hostCfgPath = "C:\Program Files (x86)\Intapp\Time\hosts.cfg"

# Directory path
$hostCfgDir = Split-Path -Path $hostCfgPath

# Ensure directory exists
if (-Not (Test-Path $hostCfgDir)) {
    New-Item -ItemType Directory -Path $hostCfgDir -Force | Out-Null
}

# Define exact content with literal $ sign
$correctContent = @"
[IntappTime]
host=https://time.jacksonlewis.com/Intapptime
secure=N
db=IntappTime
 
[Settings]
HideTimeReview=Y
ClientInstallDataFolder=`$Appdatadir\Intapp\Time\Data
"@

# Write exact content to file
$correctContent | Set-Content -Path $hostCfgPath -Encoding UTF8 -Force

Write-Output "Remediation complete: host.cfg replaced with exact expected content."
Exit 0
