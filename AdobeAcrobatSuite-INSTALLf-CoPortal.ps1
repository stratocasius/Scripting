### Adobe Acrobat 25.001 Suite Update(Company Portal) - 12/31/2025
### Includes removal/update of ndOffice Suite. Filename - AdobeAcrobatSuite-INSTALLf-CoPortal.ps1 
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\AdobeAcrobatSuite-CoPortal-Transcript.log"
### Start logging
Start-Transcript -Append $logFilepath
# Track script duration
$global:ScriptStartTime = Get-Date
### Disk space pre-check (C:)
### Requires at least 4 GB free
$RequiredFreeGB = 4
try {
    $cDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
    $freeGB = [Math]::Round(($cDrive.FreeSpace / 1GB), 2)

    if ($freeGB -lt $RequiredFreeGB) {
        $msg = "ERROR: Insufficient free space on C:. Required: ${RequiredFreeGB}GB, Available: ${freeGB}GB. Exiting."
        # Log (even before transcript starts)
        Add-Content -Path $logFilepath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $msg"
        Write-Output $msg
        exit 1
    }
    else {
        $msg = "OK: Free space check passed. Available on C:: ${freeGB}GB (Required: ${RequiredFreeGB}GB)."
        Add-Content -Path $logFilepath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $msg"
        Write-Output $msg
    }
}
catch {
    $msg = "ERROR: Unable to determine free space on C:. $($_.Exception.Message) Exiting."
    Add-Content -Path $logFilepath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $msg"
    Write-Output $msg
    exit 1
}
### Kill remnant processes if found running.
Stop-Process -Name winword -Force -ErrorAction SilentlyContinue
Stop-Process -Name outlook -Force -ErrorAction SilentlyContinue
Stop-Process -Name excel -Force -ErrorAction SilentlyContinue
Stop-Process -Name powerpnt -Force -ErrorAction SilentlyContinue
Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue
Stop-Process -Name msedge -Force -ErrorAction SilentlyContinue
Stop-Process -Name ndOffice -Force -ErrorAction SilentlyContinue
Stop-Process -Name NetDocuments.ndMail.Application -Force -ErrorAction SilentlyContinue
Stop-Process -Name ndClickWinTray -Force -ErrorAction SilentlyContinue
Stop-Process -Name ndAdobe -Force -ErrorAction SilentlyContinue
Stop-Process -Name powerPDF -Force -ErrorAction SilentlyContinue
#region Removals
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
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /norestart /l*v C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndClick-UNINSTALL.log"
            }
               Write-Output "Attempted to uninstall $displayName $displayVersion."
               Write-Output "Successfully uninstalled $displayName $displayVersion at $(Get-Date)."
        }
    }
}
#######################
### ndOffice removal if found
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($displayName -like "Netdocuments ndOffice") {
            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            # Log details
            Write-Output "Found $displayName with version $displayVersion, Uninstalling"
                        # Uninstall the software
            if ($uninstallString -like "MsiExec.exe*") {
                $uninstallString = $uninstallString -replace '/I', '/X'
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /norestart /l*v C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndOffice-UNINSTALL.log"
            }
               Write-Output "Attempted to uninstall $displayName $displayVersion."
               Write-Output "Successfully uninstalled $displayName $displayVersion at $(Get-Date)."
        }
    }
}
#######################
### ndMail removal if found
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($displayName -like "Netdocuments ndMail") {
            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            # Log details
            Write-Output "Found $displayName with version $displayVersion, Uninstalling"
                        # Uninstall the software
            if ($uninstallString -like "MsiExec.exe*") {
                $uninstallString = $uninstallString -replace '/I', '/X'
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /norestart /l*v C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndMail-UNINSTALL.log"
            }
               Write-Output "Attempted to uninstall $displayName $displayVersion."
               Write-Output "Successfully uninstalled $displayName $displayVersion at $(Get-Date)."

        }
    }
}
#######################
### ndMail Folder Mapping removal if found
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($displayName -like "Netdocuments ndMail Folder Mapping") {
            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            # Log details
            Write-Output "Found $displayName with version $displayVersion, Uninstalling"
                        # Uninstall the software
            if ($uninstallString -like "MsiExec.exe*") {
                $uninstallString = $uninstallString -replace '/I', '/X'
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /norestart /l*v C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndMailFM-UNINSTALL.log"
            }
               Write-Output "Attempted to uninstall $displayName $displayVersion."
               Write-Output "Successfully uninstalled $displayName $displayVersion at $(Get-Date)."

        }
    }
}
#######################
### ndAdobe removal if found
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($displayName -like "Netdocuments ndAdobe") {
            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            # Log details
            Write-Output "Found $displayName with version $displayVersion, Uninstalling"
                        # Uninstall the software
            if ($uninstallString -like "MsiExec.exe*") {
                $uninstallString = $uninstallString -replace '/I', '/X'
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /norestart /l*v C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndAdobe-UNINSTALL.log"
            }
               Write-Output "Attempted to uninstall $displayName $displayVersion."
               Write-Output "Successfully uninstalled $displayName $displayVersion at $(Get-Date)."

        }
    }
}
#######################
# Check for "Netdocuments ndOffice Installer" in the specified registry paths
$uninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$targetDisplayName = "Netdocuments ndOffice Installer"
$ndFound = $false

foreach ($path in $uninstallPaths) {
    if (Test-Path $path) {
        try {
            $apps = Get-ItemProperty -Path (Join-Path $path "*") -ErrorAction SilentlyContinue
            foreach ($app in $apps) {
                if ($null -ne $app.DisplayName -and $app.DisplayName -eq $targetDisplayName) {
                    Write-Host "Found target application in registry path: $path"
                    $ndFound = $true
                }
            }
        }
        catch {
            Write-Warning "Failed to read registry path: $path. Error: $_"
        }
    }
    else {
        Write-Warning "Registry path does not exist: $path"
    }
}

if ($ndFound) {
    $uninstallExe = ".\ndOfficeSetup401.exe"
    $arguments   = "/uninstall /quiet /norestart /log C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndOfficeInstaller401EXE-UNINSTALL.log"

    if (Test-Path $uninstallExe) {
        Write-Host "Netdocuments ndOffice Installer detected. Running uninstall..."
        try {
            # Set-Location -Path "C:\jltools\AdobeAcrobatSuite" - commented out for Company Portal usage.
            Start-Process -FilePath $uninstallExe -ArgumentList $arguments -Wait -NoNewWindow
            Write-Host "Uninstall command for ndOffice Installer completed on $(Get-Date)."
        }
        catch {
            Write-Error "Failed to run uninstall command. Error: $_"
        }
    }
    else {
        Write-Error "Uninstall executable not found at path: $uninstallExe"
    }
}
else {
    Write-Host "Netdocuments ndOffice Installer not found in the specified registry locations."
}
#######################
### ndOffice Installer removal if found
#$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
#foreach ($path in $uninstallKeys) {
#    Get-ChildItem $path | ForEach-Object {
#        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
#        if ($displayName -like "Netdocuments ndOffice Installer") {
#            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
#            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            # Log details
#            Write-Output "Found $displayName with version $displayVersion, Uninstalling"
                        # Uninstall the software
#            if ($uninstallString -like "MsiExec.exe*") {
#                $uninstallString = $uninstallString -replace '/I', '/X'
#                Set-Location -Path "C:\jltools\AdobeAcrobatSuite"
#                Start-Process -Wait ".\ndOfficeSetup401.exe" -ArgumentList "/uninstall /quiet /norestart /log C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndOfficeInstaller-UNINSTALL.log"
 #           }
 #              Write-Output "Attempted to uninstall $displayName $displayVersion."
 #              Write-Output "Successfully uninstalled $displayName $displayVersion at $(Get-Date)."

        #}
   # }
#}
#######################
#region Adobe Acrobat installation
# Adding gccustomhook.exe to CFA exclusion list
Write-Output "Adding gccustomhook.exe to CFA exclusion list..."
Add-MpPreference -ControlledFolderAccessAllowedApplications "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AdobeGenuineClient\customhook\gccustomhook.exe" -Force 
Write-Output "gccustomhook.exe added to CFA exclusion list."

$setupPath = ".\setup.exe"
if (Test-Path $setupPath) {
    # Set-Location -Path "C:\jltools\AdobeAcrobatSuite" - commented out for Company Portal usage.
    Start-Process -FilePath $setupPath -Wait ### removed  -ArgumentList "--silent"
    Write-Host "Installation of Adobe Acrobat 25.001 completed at $(get-Date)."
} else {
    Write-Host "Error - Adobe Acrobat 25.001 not found at the specified path."
}
### Removing gccustomhook.exe to CFA exclusion list
Write-Output "gccustomhook.exe to CFA exclusion list..."
Remove-MpPreference -ControlledFolderAccessAllowedApplications "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AdobeGenuineClient\customhook\gccustomhook.exe" -Force
Write-Output "gccustomhook.exe removed from CFA exclusion list."
#######################

#region ndOffice 4.2.1 app installations
$setupPath = ".\ndOfficeSetup.exe"
if (Test-Path $setupPath) {
    Start-Process -FilePath $setupPath -ArgumentList "/install", "/quiet", "/norestart" -Wait
    Write-Host "Installation of ndOfficeSetup.exe completed at $(get-Date)."
} else {
    Write-Host "Error: ndOfficeSetup.exe not found at the specified path."
}
### ndMail
# Set-Location -Path "C:\jltools\AdobeAcrobatSuite" - commented out for Company Portal usage.
$ndMail="ndMailSetup.msi"
$ndMailARGs="/I $ndMail /qn /l C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndMail116-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailARGs -wait -nonewwindow
Write-Host "Installation of ndMail 1.16 completed at $(get-Date)."
### ndMailFM
$ndMailFM="ndMailFolderMappingx64.msi"
$ndMailFMARGs="/I $ndMailFM /qn /l C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndMailFM8805-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailFMARGs -wait -nonewwindow
Write-Host "Installation of ndMail Folder Mapping 1.0.8805 completed at $(get-Date)."
###############################################################################
#region Create function for remediation logging
$LogFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndOfficeHKLMSettings-Remediation.log"

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
#region Define "HKLM:\Software\NetVoyage\NetDocuments" registry key path
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
#region Define "HKLM:\SOFTWARE\NetDocuments\ndMail" registry key path
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
### Start-Process -FilePath "C:\Program Files (x86)\NetDocuments\ndOffice\ndOffice.exe"
#region Unregister/Delete Task Scheduler item
# Unregister-ScheduledTask -TaskName AdobeAcrobatSuite -Confirm:$false 
# Write-Output "Task Scheduler item AdobeAcrobatSuite removed on $(Get-Date)"
### Cleanup C:\jltools\AdobeAcrobatSuite folder
## Remove-Item -Path C:\jltools\AdobeAcrobatSuite -Force -ErrorAction SilentlyContinue
## Write-Output "Staging folder at C:\jltools\AdobeAcrobatSuite removed on $(Get-Date)"
# Calculate script duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("Adobe Acrobat Suite install total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
Stop-Transcript