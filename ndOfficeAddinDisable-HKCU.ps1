# Define the root registry path and target subkey
Set-Location -Path Registry::HKEY_USERS
# $RootPath = Get-ChildItem -Path Registry::HKEY_USERS
$TargetSubKey = "Software\Microsoft\Office\Outlook\Addins\NetDocuments.ndMail.OutlookAddIn"
$TargetValueName = "LoadBehavior"
$DesiredValue = 2

# Get all user SIDs under HKEY_USERS, excluding system keys
$UserSIDs = Get-ChildItem -Path Registry::HKEY_USERS | Where-Object {
    $_.Name -notmatch "^S-1-5-(18|19|20)$"
}

# Loop through each user SID
foreach ($UserSID in $UserSIDs) {
    # Construct the full path to the target subkey
    $RegistryPath = Join-Path -Path $UserSID.PSPath -ChildPath $TargetSubKey

    # Check if the registry path exists
    if (Test-Path -Path $RegistryPath) {
        try {
            # Get the current value of LoadBehavior
            $CurrentValue = (Get-ItemProperty -Path $RegistryPath -Name $TargetValueName -ErrorAction Stop).$TargetValueName

            # Check if the current value is not equal to the desired value
            if ($CurrentValue -ne $DesiredValue) {
                # Update LoadBehavior to the desired value
                Set-ItemProperty -Path $RegistryPath -Name $TargetValueName -Value $DesiredValue
                Write-Output "Updated LoadBehavior for $RegistryPath to $DesiredValue."
            } else {
                Write-Output "LoadBehavior for $RegistryPath is already set to $DesiredValue."
            }
        } catch {
            Write-Output "An error occurred while processing $RegistryPath $($_.Exception.Message)"
        }
    } else {
        Write-Output "Registry path $RegistryPath does not exist. Skipping."
    }
}