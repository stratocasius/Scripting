# Variables
$registryPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\Spelling"
$valueName = "Check"
$valueData = 1

try {
    # Check if the registry path exists
    if (-not (Test-Path -Path $registryPath)) {
        # Create the registry path if it does not exist
        Write-Output "Registry path '$registryPath' does not exist. Creating it..."
        New-Item -Path $registryPath -Force | Out-Null
        Write-Output "Registry path created successfully."
    } else {
        Write-Output "Registry path '$registryPath' already exists."
    }

    # Check if the value exists and set it
    $currentValue = (Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue).$valueName
    if ($currentValue -ne $valueData) {
        Write-Output "Setting registry value '$valueName' to '$valueData'..."
        New-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -PropertyType DWORD -Force | Out-Null
        Write-Output "Registry value set successfully."
    } else {
        Write-Output "Registry value '$valueName' is already set to '$valueData'. No changes needed."
    }
}
catch {
    Write-Error "An error occurred: $_"
}