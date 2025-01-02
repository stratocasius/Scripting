# Define the registry path
$regPath = "HKCU:\Software\NetVoyage\NetDocuments"

# Define the registry entries and their desired values
$registryEntries = @{
    "useMapi" = "true"
    "LoginRepoID" = "CA-2V8C78SD"
    "UseEmbeddedNetWebBrowser" = "true"
}

try {
    # Check and set each registry entry
    foreach ($entry in $registryEntries.GetEnumerator()) {
        $name = $entry.Key
        $desiredValue = $entry.Value
        
        if (Get-ItemProperty -Path $regPath -Name $name -ErrorAction SilentlyContinue) {
            $currentValue = (Get-ItemProperty -Path $regPath -Name $name).$name
            if ($currentValue -ne $desiredValue) {
                Write-Output "Remediation needed for registry value '$name' at '$regPath' from '$currentValue' to '$desiredValue'."
                Exit 1
                # Set-ItemProperty -Path $regPath -Name $name -Value $desiredValue -PropertyType String
            } else {
                Write-Output "Registry value '$name' at '$regPath' is already set to '$desiredValue'."
                Exit 0
            }
        } else {
            Write-Output "Registry key '$regPath' or value '$name' does not exist. Remediation needed setting to '$desiredValue'."
            Exit 1
            # New-ItemProperty -Path $regPath -Name $name -Value $desiredValue -PropertyType String
        }
    }

} catch {
    Write-Output "An error occurred: $_"
    Exit 1
}
