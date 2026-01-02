### SnagIt 25.1.1 with custom MST file.
# Track script start time (before anything else happens)
$global:ScriptStartTime = Get-Date
$LogFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\SnagIt25.1.1-Transcript.log"
### Ensure the log directory exists
$LogDir = Split-Path -Path $LogFile -Parent
if (-not (Test-Path -Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}
### Start logging
Start-Transcript -Path $LogFile
### Copy transform file.
Copy-Item -Path "snagit.mst" -Destination "C:\Windows\Temp" -Force -ErrorAction Stop
### Run LiteraDocXtools11.25.1_x64.msi with parameters
$SnagIt = "snagit.msi"
$SnagItARGs = "/I $SnagIt /qn TRANSFORM=C:\Windows\Temp\snagit.mst /l*v C:\programdata\Microsoft\IntuneManagementExtension\Logs\SnagIt25.1.1-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $SnagItARGs -wait -nonewwindow
Write-Output "Successfully completed install for SnagIt 25.1.1 on $(Get-Date)"
# Calculate duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("Snagit 25.1.1 total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
Stop-Transcript