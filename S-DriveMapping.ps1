$DriveLetter = "S:\"
$UsernameFolder = "$env:USERNAME"
$UserPath = Join-Path -Path $DriveLetter -ChildPath $UsernameFolder

# Ensure S:\ drive exists
if (Test-Path -Path $DriveLetter) {
    # Create the folder if it does not exist
    if (-not (Test-Path -Path $UserPath)) {
        New-Item -Path $UserPath -ItemType Directory -Force
        Write-Output "Created user folder at $UserPath"
    } else {
        Write-Output "User folder already exists at $UserPath"
    }
} else {
    Write-Output "Drive S:\ is not mapped. Ensure network drive mapping is in place."
}