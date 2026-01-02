### Zoom Workplace 6.2.49050 detection script - 10/31/2024
# Define the target DisplayName and minimum required version
$targetDisplayName = "Zoom Workplace (64-bit)"
$minVersion = "6.2.49050"

# Define the registry path to search for the application
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"

# Function to compare versions
function Compare-Version ($ver1, $ver2) {
    $v1 = [version]$ver1
    $v2 = [version]$ver2
    return $v1 -ge $v2
}

# Get all subkeys under the target registry path
$subkeys = Get-ChildItem -Path $registryPath -ErrorAction SilentlyContinue

# Initialize variable to track if the app is found with the correct version
$appDetected = $false

# Loop through each subkey
foreach ($subkey in $subkeys) {
    # Retrieve the DisplayName and DisplayVersion values for the current subkey
    $displayName = (Get-ItemProperty -Path $subkey.PSPath -ErrorAction SilentlyContinue).DisplayName
    $displayVersion = (Get-ItemProperty -Path $subkey.PSPath -ErrorAction SilentlyContinue).DisplayVersion

    # Check if the DisplayName matches the target name
    if ($displayName -eq $targetDisplayName) {
        # Check if DisplayVersion meets or exceeds the minimum required version
        if (Compare-Version -ver1 $displayVersion -ver2 $minVersion) {
            $appDetected = $true
            break
        }
    }
}
# Output detection status
if ($appDetected) {
    Write-Output "Zoom Workplace 6.2.49050 installer detected version 6.2.49050 or higher installed on $env:COMPUTERNAME."
   exit 0 # Success, application is installed
} else {
    Write-Output "Zoom Workplace 6.2.49050 installer detected Teamviewer installed version is too low and Zoom Workplace 6.2.49050 will be installed."
   exit 1 # Failure, application is not installed
}
