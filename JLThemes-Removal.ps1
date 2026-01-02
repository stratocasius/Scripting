### JLThemes Removal Script - 07312025
### Removes thmx file and associated HKCU detection for JLThemes-INSTALL app.
$ErrorActionPreference = "Stop"

# Resolve paths
$appDataPath = [Environment]::GetFolderPath("ApplicationData")
$localAppDataPath = [Environment]::GetFolderPath("LocalApplicationData")
$themeFilePath = Join-Path -Path $appDataPath -ChildPath "Microsoft\Templates\Document Themes\JacksonLewis.thmx"
$logDirectory = Join-Path -Path $localAppDataPath -ChildPath "Microsoft\Temp"
$logFile = Join-Path -Path $logDirectory -ChildPath "JLThemes-Removal.log"
$registryPath = "HKCU:\Software\Intune"
$registryValue = "IntuneApp_JLThemes"

# Ensure log directory exists
if (!(Test-Path -Path $logDirectory)) {
    New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
}

# Start logging
Start-Transcript -Path $logFile -Append

Write-Host "Starting JLThemes removal process..."

# Remove theme file
if (Test-Path -Path $themeFilePath) {
    Remove-Item -Path $themeFilePath -Force
    Write-Host "Removed file: $themeFilePath"
} else {
    Write-Host "File not found: $themeFilePath"
}

# Remove registry value if it exists
if (Test-Path $registryPath) {
    $regValue = Get-ItemProperty -Path $registryPath -Name $registryValue -ErrorAction SilentlyContinue
    if ($regValue) {
        Remove-ItemProperty -Path $registryPath -Name $registryValue
        Write-Host "Removed registry value: $registryPath\$registryValue"
    } else {
        Write-Host "Registry value not found: $registryPath\$registryValue"
    }
} else {
    Write-Host "Registry path not found: $registryPath"
}

Write-Host "JLThemes removal process completed."

Stop-Transcript