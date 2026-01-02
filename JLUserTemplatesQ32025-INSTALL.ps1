### JL Office Templates Q3 2025 Install - 07022025
### NOTE: New logging path for Current User based apps/detection - "$env:LOCALAPPDATA\Microsoft\Temp\JLUserTemplatesQ22025-Transcript.log"

# Track script duration
$global:ScriptStartTime = Get-Date

# Define log path and start transcript
$LogFilePath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\Temp\JLUserTemplatesQ32025-Transcript.log"
Start-Transcript -Path $LogFilePath | Out-Null

### Remove flattened file if it exists
$TargetPath = Join-Path -Path $env:APPDATA -ChildPath "Microsoft"
$TargetFile = Join-Path -Path $TargetPath -ChildPath "Templates"

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
$templateSource = "C:\jltools\JLTemplates"

# Ensure the staging folder exists
if (-not (Test-Path $templateSource)) {
    New-Item -Path $templateSource -ItemType Directory -Force | Out-Null
    Write-Output "Created staging folder: $templateSource"
} else {
    Write-Output "$templateSource already exists. Continuing..."
}

# Define the templates to copy
$templateFiles = @(
    "Blue Back.dot",
    "CAPTION.DOT",
    "Chubb Info Form.dotm",
    "FILE INFO SHEET.dotm",
    "General Release.dot",
    "InsuranceForm.dot",
    "JLFax.dotm",
    "JLLetter.dotm",
    "JLLetter2.dotm",
    "JLMemo.dotm",
    "JL Standard Brief Template.dotx",
    "JL Standard Position Statement Template.dotx",
    "OfficeLocation.txt",
    "personal.ini",
    "RetainerForm.dot",
    "Watermarks.ini"
)

# Copy templates to staging area
Copy-Item $templateFiles -Destination $templateSource -Recurse -Force -Verbose | Out-Null
Write-Output "Copied JL User Templates to staging folder: $templateSource on $(Get-Date)"

# Define current user Templates folder path
$UserTemplateFolder = Join-Path -Path $env:APPDATA -ChildPath "Microsoft\Templates"

# Ensure Templates folder exists
if (-not (Test-Path $UserTemplateFolder)) {
    New-Item -Path $UserTemplateFolder -ItemType Directory -Force | Out-Null
    Write-Output "Created Templates folder at $UserTemplateFolder"
}

# Copy each template to current user's Templates folder
foreach ($file in $templateFiles) {
    $sourceFile = Join-Path $templateSource $file
    $destinationFile = Join-Path $UserTemplateFolder $file

    if (Test-Path $sourceFile) {
        Copy-Item -Path $sourceFile -Destination $destinationFile -Force | Out-Null
        Write-Output "Copied $file to $UserTemplateFolder"
    } else {
        Write-Output "$file not found in $templateSource. Skipping..."
    }
}

# Set registry detection key for current user
$detectionRegPath = "HKCU:\Software\Intune"
$detectionRegName = "IntuneApp_JLUserTemplatesQ32025"
$detectionRegValue = "07022025"

if (-not (Test-Path -Path $detectionRegPath)) {
    New-Item -Path $detectionRegPath -Force | Out-Null
}

Set-ItemProperty -Path $detectionRegPath -Name $detectionRegName -Value $detectionRegValue | Out-Null
Write-Output "Registry detection key set to HKCU:\Software\Intune\$detectionRegName with value $detectionRegValue."

# Clean up staging
Set-Location -Path $templateSource | Out-Null
Remove-Item $templateFiles -Recurse -Force -Verbose | Out-Null
Write-Output "Staging templates removed from $templateSource on $(Get-Date)"

# Return to safe directory
Set-Location -Path "C:\Windows\System32" | Out-Null

# Script completion and duration logging
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("JL User Templates total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)

# End transcript
Stop-Transcript