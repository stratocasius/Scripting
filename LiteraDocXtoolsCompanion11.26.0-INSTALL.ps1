### Litera DocXTools Companion 11.26.0.2 Installer  07/08/2025
$global:ScriptStartTime = Get-Date
$LogFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LiteraDocXToolsCompanion11.26.0-Autopilot-Transcript.log"
# Ensure the log directory exists
$LogDir = Split-Path -Path $LogFile -Parent
if (-not (Test-Path -Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}
Start-Transcript -Path $LogFile
### Rundll32.exe process AV exclusion
Add-MpPreference -ExclusionProcess "C:\Windows\System32\rundll32.exe" -Force
Write-Output "rundll32.exe exclusion added to Defender on $(Get-Date)"
### Install DocXTools Companion 11.26.0
$LiteraDocXToolsComp = "LiteraDocXtoolsCompanion_11.26.0_x64.msi"
$LiteraDocXToolsCompARGs = "/I $LiteraDocXToolsComp PRODUCT_KEY=DC-300Iw2l-ST0-X-QD75F ACCEPT_EULA_AND_TPLA=1 RIBBON_OPTION=LiteraTab.xml GUIDED=0 /qn /l*v C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LiteraDocXCompanion11.26.0-Autopilot-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraDocXToolsCompARGs -wait -nonewwindow
Write-Output "DocXTools Companion 11.26.0 has been installed successfully on $(Get-Date)"
### Remove exclusion from C:\Windows\System32\rundll32.exe from AV
Remove-MpPreference -ExclusionProcess "C:\Windows\System32\rundll32.exe" -Force
Write-Output "rundll32.exe exclusion removed from Defender on $(Get-Date)"
# Calculate duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("DocXTools Companion 11.26.0 Installer total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
Stop-Transcript