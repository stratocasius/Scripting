### Expert Collections Outlook Addin 8.2.2(includes Trusted Sites addition of https://ADRTRAINAPPS.jacksonlewis.net to HKCU - 11/15/2024
### Adding the Trusted Site
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\ExpertOutlookAddin-Transcript.log"
### Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\ExpertOutlookAddin-Transcript.log"
# Initialize an empty array to store uninstalled applications
# Define the target registry path based on the provided .reg file
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\jacksonlewis.net\ADRTRAINAPPS"

# Check if the registry path exists; if not, create it
if (!(Test-Path -Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the "https" value to dword:00000002, which corresponds to Trusted Sites (Zone 2)
New-ItemProperty -Path $registryPath -Name "https" -PropertyType DWord -Value 2 -Force | Out-Null

# Output a success message
Write-Output "The URL https://ADRTRAINAPPS.jacksonlewis.net has been added to Trusted Sites for the current user."

### Installing the Expert Collections Outlook Addin
$ExpertOutlookAddin = "ExpertOutlookAddInMsiPerMachine.msi"
$ExpertOutlookAddinARGs = "/I $ExpertOutlookAddin /qn /l*v C:\programdata\microsoft\IntuneManagementExtension\Logs\ExpertCollectionsOutlookAddin8.2.2-INSTALL.log"
Write-Output "Starting Litera Compare installation with the following arguments: $ExpertOutlookAddinARGs"
Start-Process "msiexec.exe" -ArgumentList $ExpertOutlookAddinARGs -Wait -NoNewWindow
Write-Output "Expert Outlook Addin installation completed on $(Get-Date)."
### Stop Transcript
Stop-Transcript