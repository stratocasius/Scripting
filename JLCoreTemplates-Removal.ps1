### JL Core Templates App - Script to Copy .dotm Files to User Templates Folder - 02/25/2025
### Create function for remediation logging
$LogFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\JLCoreTemplates-Removal-Transcript.log"
Start-Transcript -Path $LogFilePath
### Establish templates
$templateFiles = @("JLFax.dotm", "JLLetter.dotm", "JLLetter2.dotm", "JLMemo.dotm")

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
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Intune\" -Name IntuneApp_JLCoreTemplates -Force -Verbose -ErrorAction SilentlyContinue
Write-Output "JL Core Templates app detection removed from HKLM:\SOFTWARE\Intune\ and reg string IntuneApp_JLCoreTemplates on $(Get-Date)"
### Stop Transcript
Stop-Transcript