# Ensure the BitLocker module is imported
Import-Module BitLocker

# Define the transcript file path
$timestamp = Get-Date -Format "yyyyMMddHHmm"
$transcriptPath = "C:\Windows\Temp\Bitlocker2GoAzureEscrow-$timestamp.log"

# Start the transcript
Start-Transcript -Path $transcriptPath -Append

# Get all removable and USB drives, excluding the system drive "C:"
$Drives = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { ($_.DriveType -eq 2 -or $_.DriveType -eq 3) -and $_.DeviceID -ne "C:" } | Select-Object -ExpandProperty DeviceID

foreach ($DeviceID in $Drives) {
    # Get BitLocker volume information
    $BLV = Get-BitLockerVolume -MountPoint $DeviceID

    if ($BLV) {
        # Find the RecoveryPassword key protector
        $RecoveryPasswordProtector = $BLV.KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }

        if ($RecoveryPasswordProtector) {
            try {
                BackupToAAD-BitLockerKeyProtector -MountPoint $DeviceID -KeyProtectorId $RecoveryPasswordProtector.KeyProtectorId -ErrorAction Stop
                Write-Host "Successfully backed up BitLocker recovery password for $DeviceID"
            } catch {
                Write-Host "Failed to back up BitLocker recovery password for $DeviceID : $_"
            }
        } else {
            Write-Host "No RecoveryPassword key protector found on $DeviceID"
        }
    } else {
        Write-Host "No BitLocker volume found on $DeviceID"
    }
}

# Stop the transcript
Stop-Transcript
