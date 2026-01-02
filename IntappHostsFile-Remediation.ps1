### Intapp Host File Remediation - Remediation Script - 03/20/2025
### Remediates any deviation in the hosts.cfg file for Intapp Time.
### Establish logging
$logFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\IntappTimeHostsRemediation-Remediation-Transcript.log"
Start-Transcript -Path $logFilePath
# Define the path to the host.cfg file
$hostCfgPath = "C:\Program Files (x86)\Intapp\Time\hosts.cfg"

# Define the required content
$expectedContent = @"
[IntappTime]
host=https://time.jacksonlewis.com/Intapptime
secure=N
db=IntappTime

[Settings]
HideTimeReview=Y
ClientInstallDataFolder=\Intapp\Time\Data
"@

# Ensure the directory exists
$hostCfgDir = Split-Path -Path $hostCfgPath
if (-Not (Test-Path $hostCfgDir)) {
    New-Item -ItemType Directory -Path $hostCfgDir -Force | Out-Null
}

# Read existing content if the file exists
if (Test-Path $hostCfgPath) {
    $fileContent = Get-Content -Path $hostCfgPath
} else {
    $fileContent = @()
}

# Define required settings
$requiredEntries = @{
    "[IntappTime]" = "[IntappTime]";
    "host=" = "host=https://time.jacksonlewis.com/Intapptime";
    "secure=" = "secure=N";
    "db=" = "db=IntappTime";
    "[Settings]" = "[Settings]";
    "HideTimeReview=" = "HideTimeReview=Y";
    "ClientInstallDataFolder=" = "ClientInstallDataFolder=\Intapp\Time\Data";
}

# Create a new content array
$newContent = @()
$foundSections = @{}

# Process existing content and ensure all required entries are present
foreach ($line in $fileContent) {
    $added = $false

    foreach ($key in $requiredEntries.Keys) {
        if ($line -match "^$key") {
            $newContent += $requiredEntries[$key]  # Ensure correct value
            $foundSections[$key] = $true
            $added = $true
            break
        }
    }

    if (-not $added) {
        $newContent += $line
    }
}

# Add missing entries
foreach ($key in $requiredEntries.Keys) {
    if (-not $foundSections.ContainsKey($key)) {
        $newContent += $requiredEntries[$key]
    }
}

# Write the updated content back to the file
$newContent | Set-Content -Path $hostCfgPath -Force

Write-Output "Remediated: host.cfg has been updated successfully."
Exit 0  # Remediation successful
Stop-Transcript