### Intapp Host File Remediation - Detection Script - 03/20/2025
### Remediates any deviation in the hosts.cfg file for Intapp Time.
### Establish logging
$logFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\IntappTimeHostsRemediation-Detection-Transcript.log"
Start-Transcript -Path $logFilePath

# Define the path to the host.cfg file
$hostCfgPath = "C:\Program Files (x86)\Intapp\Time\hosts.cfg"

# Define required settings
$requiredEntries = @(
    "[IntappTime]",
    "host=https://time.jacksonlewis.com/Intapptime",
    "secure=N",
    "db=IntappTime",
    "[Settings]",
    "HideTimeReview=Y",
    "ClientInstallDataFolder=\Intapp\Time\Data"
)

# Check if the file exists
if (-Not (Test-Path $hostCfgPath)) {
    Write-Output "Non-Compliant: host.cfg file not found."
    Exit 1  # Non-Compliant
}

# Read the content of the file
$fileContent = Get-Content -Path $hostCfgPath

# Check for missing entries
$missingEntries = @()
foreach ($entry in $requiredEntries) {
    if ($fileContent -notcontains $entry) {
        $missingEntries += $entry
    }
}

# If any required entries are missing, report non-compliance
if ($missingEntries.Count -gt 0) {
    Write-Output "Non-Compliant: Missing or incorrect entries in hosts.cfg."
    Write-Output "Missing Entries: $($missingEntries -join ', ')"
    Exit 1  # Non-Compliant
}

Write-Output "Compliant: All required entries are present in hosts.cfg."
Exit 0  # Compliant
Stop-Transcript