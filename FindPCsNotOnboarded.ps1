# Install the WindowsDefenderATP module if not already installed
Install-Module -Name WindowsDefenderATP

# Import the WindowsDefenderATP module
Import-Module -Name WindowsDefenderATP

# Connect to the Windows Defender ATP service
Connect-WDService

# Get a list of devices that are not onboarded to Windows Defender ATP
$devices = Get-MpPreference | Select-Object -ExpandProperty ExcludedProcess | Where-Object { $_.ProcessName -eq 'atpagent.exe' } | Select-Object -ExpandProperty TargetPath

# Display the list of devices
$devices
