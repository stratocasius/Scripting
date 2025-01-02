#######################################################################################################
# Detection script for Metadact Load Behavior
# Define the registry path and value name
$registryPath = "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\ZMetadact Options"
$valueName = "LoadBehavior"

# Check if the registry key exists
if (-Not (Test-Path $registryPath)) {
    Write-Output "Metadact is not installed."
    exit 0
} else {
    # Check if the 'LoadBehavior' value exists and its value
    $debugValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue
    if (-Not $debugValue -or $debugValue.$valueName -eq 3) {
        Write-Output "Loadbehavior DWORD is not set to 3, remediation required."
        exit 1
    } else {
        Write-Output "Loadbehavior value is set already to 3."
        exit 0
    }
}