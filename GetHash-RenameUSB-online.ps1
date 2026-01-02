# Create HWID directory
$HWIDPath = "C:\HWID"
New-Item -Type Directory -Path $HWIDPath -Force | Out-Null
Set-Location -Path $HWIDPath

# Get serial number
$Serial = (Get-WmiObject -Class Win32_BIOS).SerialNumber.Trim()

# Define the output CSV filename
$OutputCSV = "$HWIDPath\$Serial-AutopilotHWID.csv"

# Allow execution
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Install and run Autopilot HWID script
Install-Script -Name Get-WindowsAutopilotInfo -Force -Confirm:$false
Get-WindowsAutopilotInfo -OutputFile $OutputCSV

Get-WindowsAutopilotInfo.ps1 -Online -GroupTag "SHI CSP Enrollment"

# Find first USB drive
$usbDrive = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 } | Select-Object -First 1

if ($usbDrive -and (Test-Path $usbDrive.DeviceID)) {
    $usbPath = "$($usbDrive.DeviceID)\$Serial-AutopilotHWID.csv"
    Copy-Item -Path $OutputCSV -Destination $usbPath -Force
    Write-Output "Copied HWID file to USB drive at: $usbPath"
} else {
    Write-Output "No USB drive detected. HWID file saved only locally at: $OutputCSV"
}