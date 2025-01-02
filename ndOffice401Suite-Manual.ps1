### ndOffice 4.0.1 Suite for Autopilot - 10/08/2024
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\ndOffice401SuiteManual-INSTALL.log"
### Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\ndOffice401SuiteManual-Transcript.log"
### Manual Installer nd341suite with IE11 Removal - 01/22/2024
Stop-Process -Name winword -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name outlook -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name excel -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name powerpnt -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name chrome -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name msedge -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name ndOffice -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name NetDocuments.ndMail.Application -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name ndClickWinTray -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name powerPDF -Force -Verbose -ErrorAction SilentlyContinue
### ndClick Removal
cmd /c WMIC.exe product where "name like 'Netdocuments ndClick%'" call uninstall > C:\programdata\microsoft\IntuneManagementExtension\logs\ndClick-Manual-Removal.log
### ndOffice app installations
$ndOffice="ndOfficeSetup.msi"
$ndOfficeARGs="/I $ndOffice /qn /l C:\programdata\microsoft\IntuneManagementExtension\logs\ndOffice401Manual-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndOfficeARGs -wait -nonewwindow
$ndMail="ndMailSetup.msi"
$ndMailARGs="/I $ndMail /qn /l C:\programdata\microsoft\IntuneManagementExtension\logs\ndMail112Manual-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailARGs -wait -nonewwindow
$ndMailFM="ndMailFolderMappingx64.msi"
$ndMailFMARGs="/I $ndMailFM /qn /l C:\programdata\microsoft\IntuneManagementExtension\logs\ndMailFM8834Manual-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailFMARGs -wait -nonewwindow
###############################################################################
### Create function for remediation logging
$LogFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndOfficeHKLMSettings-Manual-Remediation.log"

# Function to write log entries
function Write-Log {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-content -Path $LogFilePath -Value "$Timestamp - $Message"
}
########################################
### HKLM Registry Settings
########################################
# Define "HKLM:\Software\NetVoyage\NetDocuments" registry key path
$RegistryPath1 = "HKLM:\Software\NetVoyage\NetDocuments"

# Define registry values to add
$RegistryValues1 = @{
    "DontShowStampConflictDialog" = "True"
    "AutoUpdateEnabled" = "False"
    "UseEmbeddedNetWebBrowser" = "True"
    "ndOfficeHandoff" = "pdf"
    "ShowExtOutlookFeatures" = "False"
    "PromptFileEmails" = "False"
    "PromptForAutomaticUpdates" = "False"
}
# Check if registry key exists
if (-not (Test-Path $RegistryPath1)) {
    # Create registry key if missing
    New-Item -Path $RegistryPath1 -Force | Out-Null
    Write-Log "Created registry key: $RegistryPath1"
    Write-Output "Created registry key: $RegistryPath1 on $(Get-Date)"
}
# Add registry values
foreach ($Name1 in $RegistryValues1.Keys) {
    $Value1 = $RegistryValues1[$Name1]
    Set-ItemProperty -Path $RegistryPath1 -Name $Name1 -Value $Value1
    Write-Log "Added registry value: $Name1 = $Value1"
    Write-Output "Created registry value: $Name1 = $Value1 on $(Get-Date)"
}
########################################
# Define "HKLM:\SOFTWARE\NetDocuments\ndMail" registry key path
$RegistryPath2 = "HKLM:\SOFTWARE\NetDocuments\ndMail" 

# Define registry values to add
$RegistryValues2 = @{
    "RankingBarEnabled" = "True"
    "ShowSuccessfulToastNotification" = "False"
    "ShowOutlookPanels" = "False"
}
# Check if registry key exists
if (-not (Test-Path $RegistryPath2)) {
    # Create registry key if missing
    New-Item -Path $RegistryPath2 -Force | Out-Null
    Write-Log "Created registry key: $RegistryPath2"
    Write-Output "Created registry key: $RegistryPath2 on $(Get-Date)"
}
# Add registry values
foreach ($Name2 in $RegistryValues2.Keys) {
    $Value1 = $RegistryValues2[$Name2]
    Set-ItemProperty -Path $RegistryPath2 -Name $Name2 -Value $Value2
    Write-Log "Added registry value: $Name2 = $Value2"
    Write-Output "Created registry value: $Name2 = $Value2 on $(Get-Date)"
}
########################################
# Define "HKLM:\SOFTWARE\Netdocuments" registry key path
$RegistryPath3 = "HKLM:\SOFTWARE\Netdocuments" 

# Define registry values to add
$RegistryValues3 = @{
    "OfflineModeNotification" = "None"
    "StampingLocation" = "LastPage"
}
# Check if registry key exists
if (-not (Test-Path $RegistryPath3)) {
    # Create registry key if missing
    New-Item -Path $RegistryPath3 -Force | Out-Null
    Write-Log "Created registry key: $RegistryPath3"
    Write-Output "Created registry key: $RegistryPath3 on $(Get-Date)"
}
# Add registry values
foreach ($Name3 in $RegistryValues3.Keys) {
    $Value1 = $RegistryValues3[$Name3]
    Set-ItemProperty -Path $RegistryPath3 -Name $Name3 -Value $Value3
    Write-Log "Added registry value: $Name3 = $Value3"
    Write-Output "Created registry value: $Name3 = $Value3 on $(Get-Date)"
}
### Relaunch ndOffice for end-user
### (Used for installing from Company Portal)
Start-Process -FilePath "C:\Program Files (x86)\NetDocuments\ndOffice\ndOffice.exe"
Stop-Transcript