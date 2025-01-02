# Function to retrieve Surface firmware version
function Get-SurfaceFirmwareVersion {
    $firmware = Get-WmiObject -Namespace "root\cimv2" -Class Win32_BIOS | Select-Object Description, Version,
    return $firmware
}


# Querying BIOS information and retrieving install date
$biosInfo = Get-WmiObject -Class Win32_BIOS -Namespace root\cimv2

if ($biosInfo) {
    $installDate = $biosInfo.ConvertToDateTime($biosInfo.InstallDate)
    Write-Host "BIOS Firmware Install Date: $installDate"
} else {
    Write-Host "Unable to retrieve BIOS information."
}