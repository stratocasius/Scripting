### JL Wallpaper 2025 - HKCU - 06/26/2025
##############################################
### NOTE: New logging path for Current User based apps/detection - "$env:LOCALAPPDATA\Microsoft\Temp\JLWallpaper2025-Transcript.log"
# Track script duration (before anything else happens)
$global:ScriptStartTime = Get-Date
### Start Transcript
$LogFilePath = "C:\users\$env:USERNAME\Appdata\Roaming\Temp\JLWallpaper2025-Transcript.log"
Start-Transcript -Path $LogFilePath

# Path to the wallpaper image file
$wallpaperPath = "C:\jltools\JLTemplates\JLWallpaper.png"

# Create the jltools\JLTemplates folder if it doesn't exist
if (-not (Test-Path $wallpaperPath)) {
    New-Item -Path $wallpaperPath -Force | Out-Null
}

### Copies PNG to location
Copy-Item -Path .\JLWallpaper.png -Destination "C:\jltools\JLtemplates" -Force | Out-Null
Write-Output "JLWallpaper.png copied to C:\jltools\JLTemplates" 

### Sets reg string to new value of location.
Set-ItemProperty -path "HKCU:Control Panel\Desktop" -name WallPaper -value "C:\jltools\JLTemplates\JLWallpaper.png" | Out-Null
Write-Output "HKCU:Control Panel\Desktop string value changed to C:\jltools\JLTemplates\JLWallpaper.png" 

### Refreshes explorer for user to intiaite change to element.
rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("JL User Templates total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
### Stop Transcript
Stop-Transcript