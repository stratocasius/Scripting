# Registry paths for the Outlook add-ins under HKCU and HKLM
$HKCUPath = "HKCU:\Software\Microsoft\Office\Outlook\Addins\"
$HKLMPath = "HKLM:\Software\Microsoft\Office\Outlook\Addins\"

# Function to get all child objects under a given registry path
function Get-RegistryChildObjects($registryPath) {
    if (Test-Path $registryPath) {
        Get-ChildItem -Path $registryPath
    } else {
        Write-Output "No child objects found under: $registryPath"
    }
}

# Get child objects under HKCU path
$HKCUChildObjects = Get-RegistryChildObjects -registryPath $HKCUPath

# Get child objects under HKLM path
$HKLMChildObjects = Get-RegistryChildObjects -registryPath $HKLMPath

# Display the results
if ($HKCUChildObjects) {
    Write-Output "Child objects under $HKCUPath:"
    $HKCUChildObjects | ForEach-Object {
        Write-Output $_.Name
    }
}

if ($HKLMChildObjects) {
    Write-Output "Child objects under $HKLMPath:"
    $HKLMChildObjects | ForEach-Object {
        Write-Output $_.Name
    }
}
