### Litera DocXTools 11.25.1.6 - Update for existing versions. 07/08/2025
### Added Copy-Item *.mdxt to C:\Program Files\Microsystems\Modules for provisioning.
# Track script start time (before anything else happens)
$global:ScriptStartTime = Get-Date
$LogFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LiteraDocXTools11.25.1.6-Autopilot-Transcript.log"
# Ensure the log directory exists
$LogDir = Split-Path -Path $LogFile -Parent
if (-not (Test-Path -Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}
# Start logging
Start-Transcript -Path $LogFile
### Run LiteraDocXtools11.25.1_x64.msi with parameters
$LiteraDocXTools = "LiteraDocXtools11.25.1_x64.msi"
$LiteraDocXToolsARGs = "/I $LiteraDocXTools PRODUCT_KEY=DX-300Iw2l-ST0-1LLMMM-Q2974 ADMINISTRATOR=0 Role=DocXtools ACCEPT_EULA_AND_TPLA=1 AUTO_DELETE_STORE=true /qn /l C:\programdata\Microsoft\IntuneManagementExtension\Logs\LiteraDocXTools11.25.1.6-Autopilot-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraDocXToolsARGs -wait -nonewwindow
Write-Output "Successfully completed install for DocXTools 11.25.1.6 on $(Get-Date)"

### Create the Modules folder if it doesn't exist
$ModulesPath = "C:\Program Files\Microsystems\Modules"
if (-not (Test-Path -Path $ModulesPath)) {
    New-Item -Path $ModulesPath -ItemType Directory -Force
Write-Output "Created Modules folder at C:\Program Files\Microsystems\Modules on $(Get-Date)"
}

### Copies .mdxt to C:\Program Files\Microsystems\Modules
$Source = '.\Microsystems.Data.Enterprise.mdxt'
Copy-Item -Path $Source -Destination "C:\Program Files\Microsystems\Modules" -Force
Write-Output "Copied .mdxt to C:\Program Files\Microsystems\Modules on $(Get-Date)"

### Copies .mdxt to each users %LOCALAPPDATA%\Microsystems\Modules folder
 $listOfNames = Get-ChildItem C:\Users -Exclude Public |Select-Object -ExpandProperty Name
 foreach ($User in $listOfNames)
 {
   New-Item -ItemType Directory -Path C:\Users\$User\appdata\Local\Microsystems\Modules -Force
    Write-Output "Created directory at C:\Users\$User\appdata\Local\Microsystems\Modules"
    Copy-Item -Path $Source -Destination C:\Users\$User\appdata\Local\Microsystems\Modules -Force
    Write-Output "Copied .mdxt C:\Users\$User\appdata\Local\Microsystems\Modules"    
 }
 # Calculate duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("DocXTools 11.25.1.6 Installer total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
Stop-Transcript