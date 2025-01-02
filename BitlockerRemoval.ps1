# Define registry paths and values
$registryEntries = @(
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\FVE"; Name = "RDVConfigureBDE"; Value = 0},
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\FVE"; Name = "RDVEnforcePassphrase"; Value = 0},
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\FVE"; Name = "RDVAllowBDE"; Value = 0},
    @{Path = "HKLM:\System\CurrentControlSet\Policies\Microsoft\FVE"; Name = "RDVDenyWriteAccess"; Value = 0}
)

# Iterate through each entry and check if it exists
foreach ($entry in $registryEntries) {
    $regPath = $entry.Path
    $regName = $entry.Name
    $regValue = $entry.Value

    # Check if the registry path exists
    if (-not (Test-Path $regPath)) {
        Write-Output "Registry path '$regPath' does not exist. Creating path..."
        New-Item -Path $regPath -Force | Out-Null
    }

    # Check if the registry value exists and has the correct value
    $currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue
    if ($null -eq $currentValue -or $currentValue -ne $regValue) {
        Write-Output "Setting registry value '$regName' to '$regValue' at '$regPath'..."
        New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWORD -Force | Out-Null
    } else {
        Write-Output "Registry value '$regName' already exists and is set correctly at '$regPath'."
    }
}

Write-Output "Registry configuration completed."