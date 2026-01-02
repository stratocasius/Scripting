### Enables the Metadact COM addin in HKCU hive. Needed in conjunction with HKLM LoadBehavior enablement.
# Define the root registry path and target subkey

$LogFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\MetadactOutlookAddinHKCU-Transcript.log"
Start-Transcript -Path $LogFilePath


### I think Dennis told us wrong, the HKCU(below) is what needs edited to 3(always load)
$RegistryPath = "HKCU:\Software\Microsoft\Office\Outlook\Addins\ZMetadact Options"
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
                ## Write-Output "Updated LoadBehavior for $RegistryPath to $DesiredValue, needs enabling ndMail within Outlook."
                Exit 1
            } else {
                Write-Output "LoadBehavior for $RegistryPath is already set to $DesiredValue."
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
    Stop-Transcript