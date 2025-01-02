
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
### ndClick removal if found
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($displayName -like "Netdocuments ndClick") {
            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            # Log details
            Write-Output "Found $displayName with version $displayVersion, Uninstalling"
                        # Uninstall the software
            if ($uninstallString -like "MsiExec.exe*") {
                $uninstallString = $uninstallString -replace '/I', '/X'
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /l*v C:\Windows\temp\ndClick-UNINSTALL.log /norestart"
            }
               Write-Output "Attempted to uninstall $displayName $displayVersion."
        }
    }
}
### Copy over files locally to C:\jltools\ndOffice40Suite
New-Item -ItemType Directory -Path "C:\jltools\ndOffice40Suite" -Force -Verbose
Copy-Item "*.*" -Destination "C:\jltools\ndOffice40Suite" -Recurse -Force -Verbose
### ndOffice app installations
$setupPath = "C:\jltools\ndOffice40Suite\ndOfficeSetup.exe"
if (Test-Path $setupPath) {
    Start-Process -FilePath $setupPath -ArgumentList "/install", "/quiet", "/norestart" -Wait
    Write-Host "Installation of ndOfficeSetup.exe completed."
} else {
    Write-Host "Error: ndOfficeSetup.exe not found at the specified path."
}
### ndMail
Start-Process -FilePath "ndMailSetup.exe" -ArgumentList "/install", "/quiet", "/norestart" -Wait
#$ndMail="ndMailSetup.msi"
#$ndMailARGs="/I $ndMail /qn /l C:\Windows\Temp\ndMail112-INSTALL.log"
#Start-Process "msiexec.exe" -ArgumentList $ndMailARGs -wait -nonewwindow
### ndMailFM
$ndMailFM="ndMailFolderMappingx64.msi"
$ndMailFMARGs="/I $ndMailFM /qn /l C:\Windows\Temp\ndMailFM8834-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailFMARGs -wait -nonewwindow
###############################################################################
### Create function for remediation logging
$LogFilePath = "C:\Windows\Temp\ndOfficeHKLMSettings-Remediation.log"

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
}
# Add registry values
foreach ($Name1 in $RegistryValues1.Keys) {
    $Value1 = $RegistryValues1[$Name1]
    Set-ItemProperty -Path $RegistryPath1 -Name $Name1 -Value $Value1
    Write-Log "Added registry value: $Name1 = $Value1"
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
}
# Add registry values
foreach ($Name2 in $RegistryValues2.Keys) {
    $Value1 = $RegistryValues2[$Name2]
    Set-ItemProperty -Path $RegistryPath2 -Name $Name2 -Value $Value2
    Write-Log "Added registry value: $Name2 = $Value2"
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
}
# Add registry values
foreach ($Name3 in $RegistryValues3.Keys) {
    $Value1 = $RegistryValues3[$Name3]
    Set-ItemProperty -Path $RegistryPath3 -Name $Name3 -Value $Value3
    Write-Log "Added registry value: $Name3 = $Value3"
}
### Relaunch ndOffice for end-user
### (Used for installing from Company Portal)Start-Process -FilePath "C:\Program Files (x86)\NetDocuments\ndOffice\ndOffice.exe"