### JL Wallpaper 2025 - 07/01/2025

$folderPath = "C:\jltools\JLTemplates"
$filePath = "$folderPath\JLWallpaper.png"
$url = "https://jlgeneralstorage.blob.core.windows.net/endpoint/JLWallpaper.png"

# Create folder if missing
if (-not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory -Force | Out-Null
    Write-Output "Created directory: $folderPath"
}

# Download the file
try {
    Invoke-WebRequest -Uri $url -OutFile $filePath -UseBasicParsing
    Write-Output "Downloaded wallpaper to: $filePath"
} catch {
    Write-Output "Failed to download wallpaper: $_"
    exit 1
}