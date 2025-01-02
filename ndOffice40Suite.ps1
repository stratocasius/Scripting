#################################################################################################################
### ndOffice 3.4.2 Suite3 - 03/12/2024
#################################################################################################################
Stop-Process -Name winword -Force -ErrorAction SilentlyContinue
Stop-Process -Name outlook -Force -ErrorAction SilentlyContinue
Stop-Process -Name excel -Force -ErrorAction SilentlyContinue
Stop-Process -Name powerpnt -Force -ErrorAction SilentlyContinue
Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue
Stop-Process -Name msedge -Force -ErrorAction SilentlyContinue
Stop-Process -Name ndOffice -Force -ErrorAction SilentlyContinue
Stop-Process -Name NetDocuments.ndMail.Application -Force -ErrorAction SilentlyContinue
Stop-Process -Name ndClickWinTray -Force -ErrorAction SilentlyContinue
Stop-Process -Name powerPDF -Force -ErrorAction SilentlyContinue
### Funtion for logging
#function Log() {
#	[CmdletBinding()]
#	param (
#		[Parameter(Mandatory=$false)] [String] $message
#	)

#	$ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
#	Log "$ts $message"
#}

$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\ndOffice40Suite-INSTALL.log"

# Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\ndOffice40Suite-Transcript.log"

# ndClick removal if found.
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($displayName -like "Netdocuments ndClick") {
            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            # Log details
            Log "Found $displayName with version $displayVersion, Uninstalling"
                        # Uninstall the software
            if ($uninstallString -like "MsiExec.exe*") {
                $uninstallString = $uninstallString -replace '/I', '/X'
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /l*v C:\Windows\temp\ndClick-UNINSTALL.log"
            }
               Add-Content -path "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\ndClick-Removal.log" -value "Attempted to uninstall $displayName $displayVersion."
        }
    }
}
### Copy over files locally to C:\jltools\ndOffice40Suite
# New-Item -ItemType Directory -Path "C:\jltools\ndOffice40Suite" -Force 
# Copy-Item "*.*" -Destination "C:\jltools\ndOffice40Suite" -Recurse -Force 
### ndOffice app installations
$setupPath = "C:\jltools\ndOffice40Suite\ndOfficeSetup.exe"
if (Test-Path $setupPath) {
    Start-Process -FilePath $setupPath -ArgumentList "/install", "/quiet", "/norestart" -Wait
    Add-Content -path $logFilepath -value "Installation of ndOfficeSetup.exe completed."
} else {
    Add-Content -path $logFilepath -value "Error: ndOfficeSetup.exe not found at the specified path."
}
### ndMail
Start-Process -FilePath "C:\jltools\ndOffice40Suite\ndMailSetup.exe" -ArgumentList "/install", "/quiet", "/norestart" -Wait
#$ndMail="ndMailSetup.msi"
#$ndMailARGs="/I $ndMail /qn /l C:\Windows\Temp\ndMail112-INSTALL.log"
#Start-Process "msiexec.exe" -ArgumentList $ndMailARGs -wait -nonewwindow
Add-Content -path $logFilepath -value "Installation of ndMail 1.14.0.1240 completed successfully."

### ndMailFM
$ndMailFM="ndMailFolderMappingx64.msi"
$ndMailFMARGs="/I $ndMailFM /qn /l C:\Windows\Temp\ndMailFM8801-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailFMARGs -wait -nonewwindow
Add-Content -path $logFilepath -value "Installation of ndMail Folder Mapping for Outlook 1.0.8801 completed successfully."

###############################################################################
### Create path for remediation logging
$RegLogFilePath = "C:\Windows\Temp\ndOfficeHKLMSettings-Remediation.log"

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
    Add-Content -path $ReglogFilePath -Value "Created registry key: $RegistryPath1"
    Add-Content -path $logFilepath -value "Added registry key: $RegistryPath1"
}
# Add registry values
foreach ($Name1 in $RegistryValues1.Keys) {
    $Value1 = $RegistryValues1[$Name1]
    Set-ItemProperty -Path $RegistryPath1 -Name $Name1 -Value $Value1
    Add-Content -path $ReglogFilePath -Value "Added registry value: $Name1 = $Value1"
    Add-Content -path $logFilepath -value "Added registry value: $Name1 = $Value1"
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
    Add-Content -path $ReglogFilePath -Value "Created registry key: $RegistryPath2"
    Add-Content -path $logFilepath -value "Added registry key: $RegistryPath2"
}
# Add registry values
foreach ($Name2 in $RegistryValues2.Keys) {
    $Value1 = $RegistryValues2[$Name2]
    Set-ItemProperty -Path $RegistryPath2 -Name $Name2 -Value $Value2
    Add-Content -path $ReglogFilePath -Value "Added registry value: $Name2 = $Value2"
    Add-Content -path $logFilepath -value "Added registry value: $Name2 = $Value2"
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
    Add-Content -path $ReglogFilePath -Value "Created registry key: $RegistryPath3"
    Add-Content -path $logFilepath -value "Added registry key: $RegistryPath3" 
}
# Add registry values
foreach ($Name3 in $RegistryValues3.Keys) {
    $Value1 = $RegistryValues3[$Name3]
    Set-ItemProperty -Path $RegistryPath3 -Name $Name3 -Value $Value3
    Add-Content -path $ReglogFilePath -Value "Added registry value: $Name3 = $Value3"
}

#Delete ndoffice shceuled task
Unregister-ScheduledTask -TaskName "ndOffice40Suite" -Confirm:$false
### Relaunch ndOffice for end-user
### (Used for installing from Company Portal)Start-Process -FilePath "C:\Program Files (x86)\NetDocuments\ndOffice\ndOffice.exe"
Stop-Transcript