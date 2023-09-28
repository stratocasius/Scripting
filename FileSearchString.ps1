# Define the file path
$filePath = "$env:Appdata\bcms\Briefcatch_License.key"

# Read the content of the file
$fileContent = Get-Content -Path $filePath

# Define the specific string you want to find and replace
$findString = "Expire=01-Oct-2023"
$replaceString = "Expire=01-Oct-2024"

# Iterate through each line in the file
$newContent = foreach ($line in $fileContent) {
    # Use the -replace operator to find and replace the specific string
    $line -replace $findString, $replaceString
}

# Overwrite the file with the updated content
$newContent | Set-Content -Path $filePath -Verbose