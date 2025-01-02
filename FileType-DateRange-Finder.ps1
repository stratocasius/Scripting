### File Finder - For file types that are created between 12/11 and 12/15/24 locally.
#######################################################################################################################################
# Define the target file extensions
$extensions = @("*.pdf", "*.tiff", "*.docx", "*.PNG", "*.jpg", "*.jpeg", "*.heic")

# Define the drive to search (e.g., C:\)
$driveToSearch = "C:\"

# Define the output file for results
$outputFile = "C:\programdata\microsoft\IntuneManagementExtension\Logs\$env:COMPUTERNAME-FilesFound.txt"

# Define the date range
$startDate = Get-Date "2024-12-11"
$endDate = Get-Date "2024-12-15"

# Initialize an array to store results
$results = @()

Write-Output "Searching for files with the extensions $($extensions -join ', ') on $driveToSearch..."
Write-Output "Filtering for files created or modified between $startDate and $endDate."

# Search for each file extension
foreach ($ext in $extensions) {
    $files = Get-ChildItem -Path $driveToSearch -Recurse -Filter $ext -ErrorAction SilentlyContinue | Where-Object {
        $_.LastWriteTime -ge $startDate -and $_.LastWriteTime -le $endDate
    }
    $results += $files
}

# Check if any results were found
if ($results.Count -gt 0) {
    # Prepare results with additional Last Modified Date information
    $resultsWithDetails = $results | Select-Object FullName, Length, @{Name = "LastModified"; Expression = {$_.LastWriteTime}}

    # Output results to the console
    $resultsWithDetails | Format-Table -AutoSize

    # Save results to the output file
    $resultsWithDetails | Out-File -FilePath $outputFile -Encoding UTF8
    Write-Output "Search completed. Results have been saved to: $outputFile"
} else {
    Write-Output "No files with the specified extensions were found within the date range on $driveToSearch."
}
