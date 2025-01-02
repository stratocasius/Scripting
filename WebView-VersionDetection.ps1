# Define the registry path and the value to check
$regPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView"
$regValue = "DisplayVersion"

# Get the version value from the registry
$version = (Get-ItemProperty -Path $regPath).$regValue

# Function to compare versions
function Compare-Version {
    param(
        [string]$v1,
        [string]$v2
    )

    $v1 = [Version]$v1
    $v2 = [Version]$v2

    return $v1.CompareTo($v2)
}

# Define the threshold version
$thresholdVersion = "129.0.0.0"

# Check if the version is below the threshold
if (Compare-Version $version $thresholdVersion -lt 0) {
    Write-Output "Edge WebView version ($version) is below $thresholdVersion"
    Exit 1
} else {
    Write-Output "Edge WebView version ($version) meets or exceeds $thresholdVersion"
    Exit 0
}
