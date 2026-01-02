# Path to the wallpaper image file
$wallpaperPath = "C:\jltools\JLTemplates\JLWallpaper.png"
$fileUri = "file:///$($wallpaperPath -replace '\\','/')"

# Registry path for setting wallpaper (applies at the machine level via Group Policy)
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\Personalization"

# Create the registry key if it doesn't exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Set registry values
New-ItemProperty -Path $regPath -Name "Wallpaper" -Value $fileUri -PropertyType String -Force
New-ItemProperty -Path $regPath -Name "WallpaperStyle" -Value "10" -PropertyType String -Force  # 2 = Stretch
New-ItemProperty -Path $regPath -Name "NoChangingWallpaper" -Value 1 -PropertyType DWord -Force

Write-Output "Desktop wallpaper set to $wallpaperPath and change is unrestricted."


#############################################################################################################################
set-itemproperty -path "HKCU:Control Panel\Desktop" -name WallPaper -value "C:\jltools\JLWallpaper.jpg" -Verbose


rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True