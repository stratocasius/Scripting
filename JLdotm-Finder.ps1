# Define the path to the file
$filePath = "C:\Program Files\Microsoft Office\root\Office16\Startup\JL.dotm"

# Check if the file exists
if (Test-Path $filePath) {
    # Get the last modified date of the file
    $lastModifiedDate = (Get-Item $filePath).LastWriteTime

    # Output the last modified date
    Write-Output "Last Modified Date of $lastModifiedDate"
} else {
    # Output a message if the file doesn't exist
    Write-Output "File $filePath does not exist"
}
