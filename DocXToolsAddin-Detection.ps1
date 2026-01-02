### Enables the DocXTools COM addin in HKCU hive. Needed in conjunction with HKLM LoadBehavior enablement. 04/17/2025
# Define the root registry path and target subkey
### I think Dennis told us wrong, the HKCU(below) is what needs edited to 3(always load)
$RegistryPath = "HKCU:\Software\Microsoft\Office\Word\Addins\Microsystems.DocXtoolsAddin"
$TargetValueName = "LoadBehavior"
$DesiredValue = 3

    # Check if the registry path exists
    if (Test-Path -Path $RegistryPath) {
        try {
            # Get the current value of LoadBehavior
            $CurrentValue = (Get-ItemProperty -Path $RegistryPath -Name $TargetValueName -ErrorAction Stop).$TargetValueName

            # Check if the current value is not equal to the desired value
            if ($CurrentValue -ne $DesiredValue) {
                # Update LoadBehavior to the desired value
                ## Set-ItemProperty -Path $RegistryPath -Name $TargetValueName -Value $DesiredValue
                Write-Output "Disabled: LoadBehavior for $RegistryPath is set to $CurrentValue, needs addin enabled in DocXTools within Word."
                Exit 1
            } else {
                Write-Output "Enabled: LoadBehavior for $RegistryPath is already set to $DesiredValue."
                Exit 0
            }
        } catch {
            Write-Output "An error occurred while processing $RegistryPath $($_.Exception.Message)"
            Exit 0
        }
    } else {
        Write-Output "Registry path $RegistryPath does not exist. Skipping."
        Exit 0
    }