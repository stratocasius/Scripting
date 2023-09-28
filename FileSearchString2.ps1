####################################################################
### BriefCatch 2.x License Remediation 2024 - 09/22/2023
####################################################################
# Define the file path
$FilePath = "$env:Appdata\bcms\Briefcatch_License.key"

# Read the content of the file
$FileContent = Get-Content -Path $filePath

# Define the specific string you want to find and replace
$FindString = "Expire=01-Oct-2023"
$ReplaceString = "Expire=01-Oct-2024"

# Iterate through each line in the file
$NewContent = foreach ($Line in $FileContent) {
    # Overwrite the file with the updated content
    $newContent | Set-Content -Path $filePath -Verbose

    else {
        # File not found, perform remediation actions here (e.g., create the file)
        Write-Host "File '$FilePath' not found. Remediation needed."
        # Example remediation action: Create the file and add the string
        New-Item -Path $FilePath -ItemType File -Force
        Set-Content -Path $FilePath -Value $SearchString
        Write-Host "File '$FilePath' created, and string '$SearchString' added."
    }
    
}