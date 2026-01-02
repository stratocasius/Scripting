### Litera Compare 11.12 - 04/30/2025

# Track script start time (before anything else happens)
$global:ScriptStartTime = Get-Date

# Start transcript
$LogFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LiteraCompare11.12-Transcript.log"
Start-Transcript -Path $LogFile -Append

######## Stop Compare service - ***COMMENTED OUT FOR Pre-Provisioning Install(ESP), used for only as an update.
### Stop-Process -Name lcp_clip -Force -ErrorAction SilentlyContinue
### Rundll32.exe process AV exclusion
### Add-MpPreference -ExclusionProcess rundll32.exe

### Litera Installers
$LiteraCompare = "LiteraCompare_11.12.msi"
$LiteraCompareARGs = "/I $LiteraCompare WORDADDIN=1 OUTLOOKADDIN=1 EXCELADDIN=1 PPTADDIN=1 OCRMODULE=1 LICENSEKEY=CD-300Iw2l-ST0-X-QD65F /norestart ACCEPT_EULA_AND_TPLA=1 /qn /l C:\programdata\microsoft\IntuneManagementExtension\Logs\LiteraCompare11.12-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraCompareARGs -wait -nonewwindow
Write-Output "Litera Compare 11.12 install successfully on $(Get-Date)"

### Litera Customizations to C:\ProgramData\Litera folder
Copy-Item -path ".\Litera" -Destination "C:\ProgramData\" -recurse -Force
Write-Output "Litera folder copied over to C:programData on $(Get-Date)"

### Remove icons from All desktops.
Remove-Item -Path "C:\users\Public\Desktop\Litera*.lnk" -Recurse -Force -Verbose
Write-Output "Removed Litera desktop icons from C:\Users\Public on $(Get-Date)"

# Calculate duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("Litera Compare 11.12 total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
Stop-Transcript