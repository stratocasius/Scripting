### Install Power Automate Desktop - 02/13/2026
### Drops off desktop icon(C:\Users\Public\Desktop)
# Runs as SYSTEM during ESP.
# Define log files
$LogFile = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\PowerAutomateDesktop-Transcript.log"

# Track script start time
$global:ScriptStartTime = Get-Date
Start-Transcript -Path $LogFile

# ---------------------------
# Copy/Install Power Automate Desktop
# ---------------------------
#Copy-Item -Path .\Setup.Microsoft.PowerAutomate.exe -Destination "C:\jltools\Logs\PAD" -Force -ErrorAction SilentlyContinue
#Set-Location -Path "C:\jltools\PAD"
Write-Output "Installing Power Automate Desktop..."
Start-Process -FilePath ".\Setup.Microsoft.PowerAutomate.exe" -ArgumentList "-s -accepteula" -Wait -NoNewWindow
Write-Output "Install Power Automate Desktop completed at $(Get-Date)."

# Create Public Desktop .url shortcut for Power Automate flow

$UrlPath = "C:\Users\Public\Desktop\JL - QA.url"
$TargetUri = "ms-powerautomate:/console/flow/run?environmentid=Default-6ab77482-4dda-43b3-9e50-82db3e426c2c&workflowid=c30efcaf-2772-4d50-8cb4-51eed25ccd94&source=Other"

$UrlContent = @"
[InternetShortcut]
URL=$TargetUri
IconFile=C:\Windows\System32\shell32.dll
IconIndex=1
"@

Set-Content -Path $UrlPath -Value $UrlContent -Encoding ASCII -Force
Write-Output "Shortcut created at $UrlPath"

# Calculate script duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("Power Automate Desktop Install total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)

Stop-Transcript