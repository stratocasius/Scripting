### ndOffice 4.0.1 Suite for Nerdio - 01/22/2025
###############################################################################
### Create function for remediation logging
$LogFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndOffice401nerdio-Transcript.log"
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\ndOffice401nerdio-Transcript.log"
### Kill remnant processes if found running.
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
# Suppress the progress bar
$ProgressPreference = 'SilentlyContinue'

# Set ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"

# URL and destination path for ndOfficeSetup.exe ndMailSetup.msi and ndMailFolderMappingx64.msi
$url = "https://jlgeneralstorage.blob.core.windows.net/endpoint/ndOfficeSetup.exe"
$dest = "C:\jltools\ndOffice401-Nerdio\ndOfficeSetup.exe"
New-Item -Path "C:\jltools\ndOffice401-Nerdio" -ItemType Directory -Force -ErrorAction SilentlyContinue
# Download ndOffice 4.0.1
Invoke-WebRequest -Uri "https://jlgeneralstorage.blob.core.windows.net/endpoint/ndOfficeSetup.exe" -OutFile "C:\jltools\ndOffice401-Nerdio\ndOfficeSetup.exe"
#################################
$url = "https://jlgeneralstorage.blob.core.windows.net/endpoint/ndMailSetup.msi"
$dest = "C:\jltools\ndOffice401-Nerdio\ndMailSetup.msi"
# Download ndMailSetup.msi
Invoke-WebRequest -Uri $url -OutFile "C:\jltools\ndOffice401-Nerdio\ndMailSetup.exe"
###
$url = "https://jlgeneralstorage.blob.core.windows.net/endpoint/ndMailFolderMappingx64.msi"
$dest = "C:\jltools\ndOffice401-Nerdio\ndMailFolderMappingx64.msi"
# Download ndMailFolderMappingx64.msi
Invoke-WebRequest -Uri $url -OutFile "C:\jltools\ndOffice401-Nerdio\ndMailFolderMappingx64.msi"

### ndOffice app installations
$setupPath = "C:\jltools\ndOffice401-Nerdio\ndOfficeSetup.exe"
if (Test-Path $setupPath) {
    Start-Process -FilePath $setupPath -ArgumentList "/install", "/quiet", "/norestart" -Wait
    Write-Host "Installation of ndOfficeSetup.exe completed at $(get-Date)."
} else {
    Write-Host "Error: ndOfficeSetup.exe not found at the specified path."
}
### ndMail
Set-Location -Path "C:\jltools\ndOffice401-Nerdio"
$ndMail="ndMailSetup.msi"
$ndMailARGs="/I $ndMail /qn /l C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndMail114-nerdioINSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailARGs -wait -nonewwindow
Write-Host "Installation of ndMail 1.14 completed at $(get-Date)."
### ndMailFM
$ndMailFM="ndMailFolderMappingx64.msi"
$ndMailFMARGs="/I $ndMailFM /qn /l C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndMailFM8801-nerdioINSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailFMARGs -wait -nonewwindow
Write-Host "Installation of ndMail Folder Mapping 1.0.8801 completed at $(get-Date)."

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
    Write-Output "Created registry key: $RegistryPath1 on $(Get-Date)"
}
# Add registry values
foreach ($Name1 in $RegistryValues1.Keys) {
    $Value1 = $RegistryValues1[$Name1]
    Set-ItemProperty -Path $RegistryPath1 -Name $Name1 -Value $Value1
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
    Write-Output "Created registry key: $RegistryPath2 on $(Get-Date)"
}
# Add registry values
foreach ($Name2 in $RegistryValues2.Keys) {
    $Value1 = $RegistryValues2[$Name2]
    Set-ItemProperty -Path $RegistryPath2 -Name $Name2 -Value $Value2
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
    Write-Output "Created registry key: $RegistryPath3 on $(Get-Date)"
}
# Add registry values
foreach ($Name3 in $RegistryValues3.Keys) {
    $Value1 = $RegistryValues3[$Name3]
    Set-ItemProperty -Path $RegistryPath3 -Name $Name3 -Value $Value3
    Write-Output "Created registry value: $Name3 = $Value3 on $(Get-Date)"
}
### Folder cleanup
Set-Location -Path "C:\Windows\System32"
Remove-Item -Path "C:\jltools\ndOffice401-Nerdio" -Recurse -Force -Verbose
Write-Output "Folder cleaned up and removed from C:\jltools\ndOffice-nerdio"
### Relaunch ndOffice for end-user
### (Used for installing from Company Portal)
### Start-Process -FilePath "C:\Program Files (x86)\NetDocuments\ndOffice\ndOffice.exe"
Stop-Transcript