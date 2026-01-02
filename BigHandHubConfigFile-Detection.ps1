### BigHand Hub Config File Detection - 04/28/2025
# Define variables
$ConfigFilePath = "C:\Program Files (x86)\BigHand\BigHand\BigHand.Client.exe.config"
$SearchString = "BHSecure.jacksonlewis.net:62000"

# Check if the file exists
if (Test-Path $ConfigFilePath) {
    # Read the file content as text
    $Content = Get-Content -Path $ConfigFilePath -Raw

    if ($Content -match [regex]::Escape($SearchString)) {
        Write-Output "All set. BH string found in config file. No remediation needed."
        exit 0
    } else {
        Write-Output "BHSecure String NOT found. Needs Remediation!"
        exit 1
    }
} else {
    Write-Output "Config file not found. Exiting..."
    exit 1
}