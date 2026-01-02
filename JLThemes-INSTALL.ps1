### JL Office Themes Install - 07312025
### NOTE: New logging path for Current User based apps/detection - "$env:LOCALAPPDATA\Microsoft\Temp\JLUserThemes-Transcript.log"

# Track script duration
$global:ScriptStartTime = Get-Date

# Define log path and start transcript
$LogFilePath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\Temp\JLUserThemes-Transcript.log"
Start-Transcript -Path $LogFilePath | Out-Null

### Remove flattened file if it exists
$TargetPath = Join-Path -Path $env:APPDATA -ChildPath "Microsoft"
$TargetFile = Join-Path -Path $TargetPath -ChildPath "Templates\Document Themes"

if (Test-Path $TargetFile -PathType Leaf) {
    try {
        Remove-Item -Path $TargetFile -Force | Out-Null
        Write-Output "Deleted flattened file: $TargetFile"
    }
    catch {
        Write-Output "Error deleting file: $_"
    }
} else {
    Write-Output "No flattened 'Templates' file found. Continuing..." | Out-Null
}

# Define the staging source folder
$ThemeSource = "C:\jltools\JLTemplates"

# Ensure the staging folder exists
if (-not (Test-Path $ThemeSource)) {
    New-Item -Path $ThemeSource -ItemType Directory -Force | Out-Null
    Write-Output "Created staging folder: $ThemeSource"
} else {
    Write-Output "$ThemeSource already exists. Continuing..."
}

# Define the templates to copy
$ThemeFile = "JacksonLewis.thmx"

# Copy templates to staging area
Copy-Item $ThemeFile -Destination $ThemeSource -Recurse -Force -Verbose | Out-Null
Write-Output "Copied Jacksonlewis.thmx to staging folder: $ThemeSource on $(Get-Date)"

# Define current user Templates folder path
$UserThemesFolder = Join-Path -Path $env:APPDATA -ChildPath "Microsoft\Templates\Document Themes"

# Ensure Templates folder exists
if (-not (Test-Path $UserThemesFolder)) {
    New-Item -Path $UserThemesFolder -ItemType Directory -Force | Out-Null
    Write-Output "Created Themes folder at $UserThemesFolder"
}

# Copy each template to current user's Templates folder
foreach ($file in $ThemeFile) {
    $sourceFile = Join-Path $ThemeSource $file
    $destinationFile = Join-Path $UserThemesFolder $file

    if (Test-Path $sourceFile) {
        Copy-Item -Path $sourceFile -Destination $destinationFile -Force | Out-Null
        Write-Output "Copied $file to $UserThemesFolder"
    } else {
        Write-Output "$file not found in $ThemeSource. Skipping..."
    }
}

# Set registry detection key for current user
$detectionRegPath = "HKCU:\Software\Intune"
$detectionRegName = "IntuneApp_JLThemes"
$detectionRegValue = "07312025"

if (-not (Test-Path -Path $detectionRegPath)) {
    New-Item -Path $detectionRegPath -Force | Out-Null
}

Set-ItemProperty -Path $detectionRegPath -Name $detectionRegName -Value $detectionRegValue | Out-Null
Write-Output "Registry detection key set to HKCU:\Software\Intune\$detectionRegName with value $detectionRegValue."

# Clean up staging
Set-Location -Path $ThemeSource | Out-Null
Remove-Item $ThemeFile -Recurse -Force | Out-Null
Write-Output "Staging theme file was removed from $ThemeSource on $(Get-Date)"

# Return to safe directory
Set-Location -Path "C:\Windows\System32" | Out-Null

# Script completion and duration logging
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("JL Themes App total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)

# End transcript
Stop-Transcript