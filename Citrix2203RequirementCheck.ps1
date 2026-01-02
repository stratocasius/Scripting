### Citrix 2203 version requirement checker.
# Define the path to the executable and the required version
$exePath = "C:\Program Files (x86)\Citrix\ICA Client\wfica32.exe"
$requiredVersion = "19.12.7000.10"

# Check if the executable exists
if (Test-Path -Path $exePath) {
    # Get the version of the executable
    $fileVersion = (Get-Item $exePath).VersionInfo.FileVersion

    # Compare the version
    if ($fileVersion -eq $requiredVersion) {
        # Exit with code 0 to signal Intune app installer to run
        Write-Host "Version 19.12.7000.10 installed"
       } else {
        # wfica version does not match.
        Write-Host "$FileVersion for Citrix found installed. Device is not applicable for update. Exiting..."
           }
} else {
    # If wfica.exe not found, cleanly exit.
    Write-Host "Citrix wfica.exe not found at $exePath. Exiting..."
   
}