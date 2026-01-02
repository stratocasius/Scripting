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
