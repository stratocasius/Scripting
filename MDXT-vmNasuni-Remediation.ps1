# Define paths and URL
$downloadUrl = "https://jlgeneralstorage.blob.core.windows.net/endpoint/Microsystems.Data.Enterprise.mdxt"
$globalDir = "C:\Program Files\Microsystems\Modules"
$userDir = "$env:LOCALAPPDATA\Microsystems\Modules"
$fileName = "Microsystems.Data.Enterprise.mdxt"

function EnsureFolder($path) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
}

function DownloadFile($targetPath) {
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $targetPath -UseBasicParsing
        Write-Output "Downloaded to $targetPath"
    } catch {
        Write-Output "Failed to download: $_"
        exit 1
    }
}

# Ensure folders exist
EnsureFolder -path $globalDir
EnsureFolder -path $userDir

# Download file to both locations
DownloadFile -targetPath (Join-Path $globalDir $fileName)
DownloadFile -targetPath (Join-Path $userDir $fileName)