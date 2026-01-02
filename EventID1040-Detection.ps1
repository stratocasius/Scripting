<#
Intune Remediation - Detection Script
Finds Application log Event ID 1040 (MsiInstaller) containing "BestAuthority_6.17.0_x64.msi"
Exit 1 = Non-compliant (matching event found)
Exit 0 = Compliant (none found)
#>

# ---- Settings ----
$TargetString   = 'BestAuthority_6.17.0_x64.msi'
$LookbackHours  = 12  # adjust as desired
$LogRoot        = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\Logs'
$LogPath        = Join-Path $LogRoot 'BestAuthority-Event1040-Detection.log'

# Ensure log directory exists
if (-not (Test-Path $LogRoot)) { New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null }

# Simple rotation if >1MB
try {
    if (Test-Path $LogPath) {
        if ((Get-Item $LogPath).Length -gt 1MB) {
            $archive = Join-Path $LogRoot ('BestAuthority-Event1040-Detection_{0:yyyyMMdd_HHmmss}.log' -f (Get-Date))
            Move-Item -Path $LogPath -Destination $archive -Force
        }
    }
} catch {}

function Write-Log {
    param([string]$Message)
    $line = "[{0:yyyy-MM-dd HH:mm:ss}] {1}" -f (Get-Date), $Message
    $line | Out-File -FilePath $LogPath -Append -Encoding UTF8
    Write-Output $line
}

try {
    $startTime = (Get-Date).AddHours(-[int]$LookbackHours)
    "==== Detection start {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date) | Out-File -FilePath $LogPath -Append -Encoding UTF8
    Write-Log "Looking for Application Event ID 1040 (MsiInstaller) containing '$TargetString' within last $LookbackHours hour(s)."

    # Filter by log, provider, event id, and time window for speed
    $events = Get-WinEvent -FilterHashtable @{
        LogName      = 'Application'
        ProviderName = 'MsiInstaller'
        Id           = 1040
        StartTime    = $startTime
    } -ErrorAction SilentlyContinue

    if ($events) {
        # Narrow to messages that include the target string
        $matches = $events | Where-Object { $_.Message -like "*$TargetString*" }
    } else {
        $matches = @()
    }

    if ($matches -and $matches.Count -gt 0) {
        $latest = $matches | Sort-Object TimeCreated -Descending | Select-Object -First 1
        Write-Log ("MATCH found: Time={0}, RecordId={1}" -f $latest.TimeCreated, $latest.RecordId)
        Write-Log "Message (first line only): $((($latest.Message -split '\r?\n')[0]) )"
        "==== Detection end (FOUND) {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date) | Out-File -FilePath $LogPath -Append -Encoding UTF8

        # concise stdout summary for Intune console:
        Write-Output ("Event 1040 detected for '{0}' at {1:yyyy-MM-dd HH:mm:ss}" -f $TargetString, $latest.TimeCreated)
        exit 1
    } else {
        Write-Log "No matching Event ID 1040 entries found."
        "==== Detection end (NONE) {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date) | Out-File -FilePath $LogPath -Append -Encoding UTF8
        exit 0
    }
}
catch {
    Write-Log ("Detection error: {0}" -f $_.Exception.Message)
    # Be conservative—trigger remediation if we can't determine
    exit 1
}
