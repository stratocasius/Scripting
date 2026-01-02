### JL User Templates Q3 2025 - Script to Copy .template files to %APPDATA%\Microsoft\Templates Folder - 07/02/2025
# Track script duration (before anything else happens)
$global:ScriptStartTime = Get-Date
### Create function for remediation logging
$LogFilePath = "$env:LOCALAPPDATA\Temp\JLUserTemplates-Removal-Transcript.log"
Start-Transcript -Path $LogFilePath
### Establish templates
$templateFiles = @("Blue Back.dot", "CAPTION.DOT", "Chubb Info Form.dotm", "FILE INFO SHEET.dotm", "General Release.dot", "InsuranceForm.dot", "JLLetter.dotm", "JLLetter2.dotm", "JLFax.dotm", "JLMemo.dotm", "JL Standard Brief Template.dotx", "JL Standard Position Statement Template.dotx", "OfficeLocation.txt")

# Get all user profiles
$userProfiles = Get-ChildItem -Path "C:\Users" -Exclude Public | Where-Object { $_.PSIsContainer }

foreach ($user in $userProfiles) {
    $userTemplatePath = "C:\Users\$($user.Name)\AppData\Roaming\Microsoft\Templates"

    # Remove each template file
    foreach ($file in $templateFiles) {
        $sourceFile = Join-Path -Path $userTemplatePath -ChildPath $file
        
        if (Test-Path -Path $sourceFile) {
            Remove-Item -Path $sourceFile -Force -Recurse -Verbose
            Write-Output "Removed $file to $userTemplatePath."
        } else {
            Write-Output "Source file $sourceFile not found. Skipping."
        }
    }
}

### Removal of detection
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Intune\" -Name IntuneApp_JLUserTemplatesQ32025 -Force -Verbose -ErrorAction SilentlyContinue
Write-Output "JL User Templates app detection removed from HKCU:\SOFTWARE\Intune\ and reg string IntuneApp_JLUserTemplatesQ32025. User templates were also removed from %Appdata%\Microsoft\Templates for all users on $(Get-Date)"
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("JL User Templates total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
### Stop Transcript
Stop-Transcript