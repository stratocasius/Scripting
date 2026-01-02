### Check and Set Registry DWORD Value
# Define registry path and values
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$DwordName = "ConsentPromptBehaviorUser"
$DesiredValue = 1

# Check if the registry key exists
if (Test-Path -Path $RegistryPath) {
    # Get current value
    $CurrentValue = (Get-ItemProperty -Path $RegistryPath -Name $DwordName -ErrorAction SilentlyContinue).$DwordName
    
    if ($CurrentValue -ne $DesiredValue) {
        # Update the DWORD value if it is not set correctly
        Set-ItemProperty -Path $RegistryPath -Name $DwordName -Value $DesiredValue -Verbose -WhatIf
        Write-Output "Updated '$DwordName' to $DesiredValue at '$RegistryPath'."
        exit 1
    } else {
        Write-Output "'$DwordName' is already set to $DesiredValue. No changes needed."
        exit 0
    }
} else {
    Write-Output "Registry path '$RegistryPath' does not exist. Creating key and setting value."
    New-Item -Path $RegistryPath -Force | Out-Null
    Set-ItemProperty -Path $RegistryPath -Name $DwordName -Value $DesiredValue -Verbose -WhatIf
    Write-Output "Created registry path and set '$DwordName' to $DesiredValue."
}