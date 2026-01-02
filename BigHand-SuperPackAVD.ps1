### BigHand SuperPack
$ErrorActionPreference = "Stop"
# Track script duration
$global:ScriptStartTime = Get-Date

# Log directory & transcript
$LogRoot = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$TranscriptLog = Join-Path $LogRoot "BigHand5.18-INSTALL-transcript.log"

if (!(Test-Path $LogRoot)) {
    New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null
}

Start-Transcript -Path $TranscriptLog -Append

Write-Output "Starting BigHand 5.18 Suite Installation on $(Get-Date)"

# Set working directory to script location
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $ScriptDir

# Installer log paths
$HubLog      = Join-Path $LogRoot "BigHandHub5.18-INSTALL.log"
$NowLog      = Join-Path $LogRoot "BigHandDesktopAssistant5.18-INSTALL.log"
$NDLog       = Join-Path $LogRoot "BigHand-NetDocs-Integration-5.18-INSTALL.log"

try {
    Write-Output "Installing BigHand Hub 5.18..."
    Start-Process "msiexec.exe" -ArgumentList "/i `"BigHand.msi`" TRANSFORMS=`"Hub_AD.mst`" BROKERADDRESS=BHSecure.jacksonlewis.net /qn /NORESTART ALLUSERS=2 /l*v `"$HubLog`"" -Wait -NoNewWindow

    Write-Output "Installing BigHand Now Assistant 5.18..."
    Start-Process "msiexec.exe" -ArgumentList "/i `"BigHandNow.msi`" TRANSFORMS=`"Now_AD_NoStartUp.mst`" BROKERADDRESS=bhsecure.jacksonlewis.net /qn /NORESTART ALLUSERS=2 /l*v `"$NowLog`"" -Wait -NoNewWindow

    Write-Output "Installing BigHand NetDocs Integration 5.18..."
    Start-Process "msiexec.exe" -ArgumentList "/i `"BigHandIntegrationwithNetDocuments.msi`" ADDLOCAL=MainFeature,NowFeature /qn /l*v `"$NDLog`"" -Wait -NoNewWindow

    Write-Output "All BigHand 5.18 components installed successfully."
    exit 0
}
catch {
    Write-Warning "An error occurred during installation: $($_.Exception.Message)"
    Stop-Transcript
    exit 1
}

# Script completion and duration logging
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("BigHand SuperPack total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
Stop-Transcript