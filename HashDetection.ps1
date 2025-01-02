# Define the path to the file
$file = "C:\Program Files\Microsystems\Modules\Microsystems.Data.Enterprise.mdxt"

# Define the expected hash
$expectedHash = "CEF2FFC9914F5827179541E839332FC8AE02D523B22FA4AE4D9C208EF282CAF8"

# Check if the file exists
if (Test-Path -Path $file) {
    # Calculate the SHA256 hash of the file
    $computedHash = (Get-FileHash -Path $file -Algorithm SHA256).Hash

    # Compare the computed hash with the expected hash
    if ($computedHash -eq $expectedHash) {
        # If the hashes match, write success to the output
        Write-Host "Detection successful: Hash matches."
        exit 0  # Success exit code for Intune detection scripts
    } else {
        # If the hashes do not match, write failure to the output
        Write-Host "Detection unsuccessful: Hash does not match."
        exit 1  # Failure exit code for Intune detection scripts
    }
} else {
    # If the file does not exist, write failure to the output
    Write-Host "Detection unsuccessful: File does not exist."
    exit 1  # Failure exit code for Intune detection scripts
}
