### JL Core Templates App - Script to Copy .dotm Files to User Templates Folder - 02/25/2025
### Create function for remediation logging
$LogFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\JLCoreTemplates-Transcript.log"
Start-Transcript -Path $LogFilePath

# Define the destination directory
$destination = "C:\jltools\JLTemplates"

# Ensure the destination folder exists; if not, create it
if (-not (Test-Path $destination)) {
    New-Item -Path $destination -ItemType Directory -Force
    Write-Output "Created destination folder: $destination"
}
else {
    Write-Output "C:\jltools\JLTemplates folder already exists."
}

### Stage the templates at C:\jltools\JLTemplates
Copy-Item -Path "*.dotm" -Destination $destination -Recurse -Force -Verbose
Write-Output "Copied JL Core Templates to staging folder: C:\jltools\JLTemplates on $(Get-Date)"

# Define template files and source location
$templateFiles = @("JLFax.dotm", "JLLetter.dotm", "JLLetter2.dotm", "JLMemo.dotm")
$templateSource = "C:\JLtools\JLtemplates"
$detectionRegPath = "HKLM:\Software\Intune"
$detectionRegName = "Remediation_JLUpdatedCoreTemplates"
$detectionRegValue = "05232023"

# Get all user profiles
$userProfiles = Get-ChildItem -Path "C:\Users" | Where-Object { $_.PSIsContainer }

foreach ($user in $userProfiles) {
    $userTemplatePath = "C:\Users\$($user.Name)\AppData\Roaming\Microsoft\Templates"

    # Ensure Templates folder exists
    if (-not (Test-Path -Path $userTemplatePath)) {
        New-Item -Path $userTemplatePath -ItemType Directory -Force
        Write-Output "Created Templates folder for $($user.Name)."
    }

    # Copy each template file
    foreach ($file in $templateFiles) {
        $sourceFile = Join-Path -Path $templateSource -ChildPath $file
        $destinationFile = Join-Path -Path $userTemplatePath -ChildPath $file

        if (Test-Path -Path $sourceFile) {
            Copy-Item -Path $sourceFile -Destination $destinationFile -Force
            Write-Output "Copied $file to $userTemplatePath."
        } else {
            Write-Output "Source file $sourceFile not found. Skipping."
        }
    }
}

### Remove staging files
Remove-Item -Path "C:\jltools\JLTemplates\*.dotm" -Recurse -Verbose -Force
Write-Output "Staging .dotm's removed from C:\jltools\JLTemplates folder on $(Get-Date)"


### Set registry detection key/values
# Check for HKLM:\Software\Intune key existance 
if (-not (Test-Path -Path $detectionRegPath)) {
    New-Item -Path $detectionRegPath -Force | Out-Null
}
### Set Detection values
Set-ItemProperty -Path $detectionRegPath -Name $detectionRegName -Value $detectionRegValue
Write-Output "Registry detection key set to $detectionRegValue."
Write-Output "JL Core Templates completed successfully on $(Get-Date)."
# Stop transcript
Stop-Transcript