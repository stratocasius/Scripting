### MDXT-Finder.ps1 - Reports the date modified for DocXTools' .mdxt file
$filePath = "C:\Program Files\Microsystems\Modules\Microsystems.Data.Enterprise.mdxt"

# Check if the file exists
if (Test-Path -Path $filePath) {
    # Get the last modified date of the file
    $file = Get-Item -Path $filePath
    $lastModified = $file.LastWriteTime

    # Output the last modified date
    Write-Output "$lastModified"
} 