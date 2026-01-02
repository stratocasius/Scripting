### Litera Metadact 5.18 - 04/26/2025
### Standalone with custom .xml files and removal of Low.pfl, High.pfl

# Track script start time (before anything else happens)
$global:ScriptStartTime = Get-Date

# Start transcript
$LogFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LiteraMetadact5.18-Transcript.log"
Start-Transcript -Path $LogFile -Append

# Exclude C:\Windows\SysWOW64\rundll32.exe from Defender
$exceptionPath = "C:\Windows\SysWOW64\msiexec.exe"
Set-MpPreference -ControlledFolderAccessAllowedApplications $exceptionPath -Verbose
Write-Output "C:\Windows\SysWOW64\msiexec.exe excluded from Defender CFA policy momentarily on $(Get-Date)."

# Install Metadact
$LiteraMetadact = "Metadact.msi"
$LiteraMetadactARGs = "/I $LiteraMetadact LICENSEKEY=MD-300Iw2l-ST0-X-Q8169 ACCEPT_EULA_AND_TPLA=1 REBOOT=ReallySuppress MSIRESTARTMANAGERCONTROL=Disable /qn /l C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LiteraMetadact5.18-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraMetadactARGs -Wait -NoNewWindow

# Remove Defender CFA exception
Remove-MpPreference -ControlledFolderAccessAllowedApplications $exceptionPath
Set-MpPreference -EnableControlledFolderAccess Enabled -Force
Write-Output "$exceptionPath exclusion removed from Defender CFA policy."

# XML and PFL file edits
# Define paths
$PflFolderPath = "C:\ProgramData\Litera\CorporateCleaningProfiles"
$XmlFolderPath = "C:\ProgramData\Litera\Customize"

# Ensure CorporateCleaningProfiles folder exists
if (-not (Test-Path -Path $PflFolderPath)) {
    New-Item -ItemType Directory -Path $PflFolderPath -Force
    Write-Output "C:\ProgramData\Litera\CorporateCleaningProfiles created on $(Get-Date)" 
}

# Ensure Customize folder exists
if (-not (Test-Path -Path $XmlFolderPath)) {
    New-Item -ItemType Directory -Path $XmlFolderPath -Force
    Write-Output "C:\ProgramData\Litera\Customize created on $(Get-Date)"
}

# Delete High.pfl and Low.pfl if they exist
$FilesToDelete = @("High.pfl", "Low.pfl")
foreach ($file in $FilesToDelete) {
    $FilePath = Join-Path -Path $PflFolderPath -ChildPath $file
    if (Test-Path -Path $FilePath) {
        Remove-Item -Path $FilePath -Force -ErrorAction SilentlyContinue
        Write-Output "$file found and deleted on $(Get-Date)"
    }
}

# Copy new .pfl files
Copy-Item -Path ".\*.pfl" -Destination $PflFolderPath -Force -ErrorAction Stop
Write-Output "Default.pfl and Leave Comments and TC.pfl copied to C:\ProgramData\Litera\CorporateCleaningProfiles folder on $(Get-Date)"

# Copy new .xml files
Copy-Item -Path ".\*.xml" -Destination $XmlFolderPath -Force -ErrorAction Stop
Write-Output "MDCustomize.xml, MDECustomize.xml, MetadactCustomize.xml and MetadactOutlookCustomize.xml copied to C:\ProgramData\Litera\Customize folder on $(Get-Date)"

# Calculate duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("Litera Metadact 5.18 total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
Stop-Transcript