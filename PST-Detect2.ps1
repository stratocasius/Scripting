# Define the search path and file extension
$searchPath = "C:\"
$fileExtension = "*.pst"

# Search for .pst files recursively
$pstFiles = Get-ChildItem -Path $searchPath -Filter $fileExtension -Recurse -ErrorAction SilentlyContinue

# Check if any .pst files were found
if ($pstFiles) {
    # Write out the locations of the found .pst files
    $pstFiles.FullName | ForEach-Object { Write-Output $_ }
    # Exit with status code 1 (files found)
    exit 1
} else {
    # Write a message indicating no files were found
    Write-Output "No .pst files found."
    # Exit with status code 1 (no files found)
    exit 0
}
