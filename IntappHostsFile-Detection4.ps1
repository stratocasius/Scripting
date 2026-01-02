### Intapp Hosts File Detection(2) - 03/26/2025
# Define the path to the host.cfg file
$logFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\IntappTimeHostsRemediation-Detection-Transcript.log"
Start-Transcript -Path $logFilePath
$hostCfgPath = "C:\Program Files (x86)\Intapp\Time\hosts.cfg"

# Define exact required content (line-by-line)
$requiredEntries = @(
    "[IntappTime]",
    "host=https://time.jacksonlewis.com/Intapptime",
    "secure=N",
    "db=IntappTime",
    "",
    "[Settings]",
    "HideTimeReview=Y",
    "ClientInstallDataFolder=`$Appdatadir\Intapp\Time\Data"
)

# Check if the file exists
if (-Not (Test-Path $hostCfgPath)) {
    Write-Output "Non-Compliant: hosts.cfg file not found."
    Exit 1
}

# Read actual file content as array of lines
$currentContent = Get-Content -Path $hostCfgPath

# Compare each line with expected line-by-line
$nonCompliantLines = @()
for ($i = 0; $i -lt $requiredEntries.Count; $i++) {
    if ($i -ge $currentContent.Count -or $currentContent[$i].Trim() -ne $requiredEntries[$i].Trim()) {
        $actual = if ($i -lt $currentContent.Count) { $currentContent[$i] } else { "<missing>" }
        $nonCompliantLines += "Line $($i + 1): Expected '$($requiredEntries[$i])' but found '$actual'"
    }
}

# If any mismatches found, report and exit
if ($nonCompliantLines.Count -gt 0) {
    Write-Output "Non-Compliant: hosts.cfg does not exactly match required content."
    $nonCompliantLines | ForEach-Object { Write-Output $_ }
    Exit 1
}

Write-Output "Compliant: hosts.cfg exactly matches the required content."
Exit 0
Stop-Transcript