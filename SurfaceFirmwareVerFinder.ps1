# Function to retrieve Surface firmware version
function Get-SurfaceFirmwareVersion {
    $firmware = Get-WmiObject -Namespace "root\cimv2" -Class Win32_BIOS | Select-Object Description, Version
    return $firmware
}

# Retrieve Surface firmware version
$surfaceFirmware = Get-SurfaceFirmwareVersion

# Output the firmware version information
if ($surfaceFirmware) {
    Write-Output "Surface Firmware Version:"
    $surfaceFirmware
} else {
    Write-Output "Unable to retrieve Surface firmware version."
}
