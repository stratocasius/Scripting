### Litera Compare 11.8 for Autopilot - 08/04/2024

# Define the log file path
$logFile = "C:\Windows\Temp\Compare11.8Autopilot-Script.log"

# Start logging
Start-Transcript -Path $logFile -Append

try {
    ### Log message before stopping the Compare service
    Write-Output "Attempting to stop the Compare service if it is running..."
    Stop-Process -Name lcp_clip -Force -ErrorAction SilentlyContinue
    Write-Output "Compare service stopped or was not running."

    ### Log message before adding Rundll32.exe to AV exclusion
    Write-Output "Adding Rundll32.exe to antivirus exclusion list..."
    Add-MpPreference -ExclusionProcess rundll32.exe
    Write-Output "Rundll32.exe added to antivirus exclusion list."

    ### Log message before starting Litera Compare installation
    $LiteraCompare = "LiteraCompare_11.8.msi"
    $LiteraCompareARGs = "/I $LiteraCompare WORDADDIN=1 OUTLOOKADDIN=1 EXCELADDIN=1 PPTADDIN=1 OCRMODULE=1 LICENSEKEY=CD-300Iw2l-ST0-X-QD65F /norestart ACCEPT_EULA_AND_TPLA=1 /qn /l C:\Windows\Temp\LiteraCompare11.8-AutoPilot-INSTALL.log"
    Write-Output "Starting Litera Compare installation with the following arguments: $LiteraCompareARGs"
    Start-Process "msiexec.exe" -ArgumentList $LiteraCompareARGs -Wait -NoNewWindow
    Write-Output "Litera Compare installation completed."

    ### Log message before removing Rundll32.exe from AV exclusion
    Write-Output "Removing Rundll32.exe from antivirus exclusion list..."
    Remove-MpPreference -ExclusionProcess rundll32.exe -Force
    Write-Output "Rundll32.exe removed from antivirus exclusion list."

    ### Log message before removing Litera icons from users desktop
    Write-Output "Removing Litera icons from the users' desktop..."
    Remove-Item -Path "C:\Users\Public\Desktop\Litera*.lnk" -Recurse -Force
    Write-Output "Litera icons removed from the users' desktop."

} catch {
    ### Log any errors that occur
    Write-Output "An error occurred: $_"
} finally {
    ### End logging
    Stop-Transcript
}