# Define the path to the file
$filePath = "C:\Program Files\Microsoft Office\root\Office16\STARTUP\JL.dotm"

# Check if the file exists
if (-Not (Test-Path -Path $filePath)) {
    Write-Error "File does not exist: $filePath"
    exit 1
}

# Compute the SHA256 hash of the file
try {
    $hashObject = Get-FileHash -Path $filePath -Algorithm SHA256
    $fileHash = $hashObject.Hash
} catch {
    Write-Error "Error computing hash for file: $_"
    exit 1
}

# Define the expected hash value
$expectedHash = "745E9D495E9408F63599B2F91132A1B2F1FB0E2CC6062F17DFDC07EA0D466DDA"

# Compare the computed hash with the expected hash
if ($fileHash -eq $expectedHash) {
	Write-Output "JL.dotm detection successful, Hash $FileHash"
    exit 0
} else {
	Write-Output "JL.dotm detection unsuccessful, Hash $FileHash"
    exit 1
}