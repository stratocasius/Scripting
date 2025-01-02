# Define the file path
$filePath = "C:\Program Files\Microsoft Office\root\Office16\STARTUP\JL.dotm"
try {
    # Check if the file exists
    if (Test-Path $filePath -PathType Leaf) {
        # Get the file version information
        $fileVersion = (Get-Item $filePath).VersionInfo.FileVersion
        # Check if the file version matches the desired version (1.0)
        if ($fileVersion -eq "1.0") {
            Write-Output "File '$filePath' exists and has version number '1.0'."
            Exit 0
            # You can perform additional actions here if needed
        } else {
            Write-Output "File JL.dotm exists but does not have version number '1.0'."
            Exit 1
            # You can add logic here to handle version mismatch
        }
    } else {
        Write-Output "File '$filePath' does not exist."
        # You can add logic here to handle file not found
        
    }
} catch {
    Write-Error "An error occurred: $_"
    # You can add error handling logic here
}
