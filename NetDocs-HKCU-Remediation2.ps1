# Define the log file location
$logDirectory = "$env:LOCALAPPDATA\Microsoft"
$logFile = "$logDirectory\NetDocs-HKCU-Remediation-$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Start the transcript
Start-Transcript -Path $logFile -Append -Force

# Define the registry path
$regPath = "HKCU:\Software\NetVoyage\NetDocuments"

# Define the registry entries and their desired values
$registryEntries = @{
    "useMapi" = "true"
    "LoginRepoID" = "CA-2V8C78SD"
    "UseEmbeddedNetWebBrowser" = "true"
}

try {
    # Ensure the registry key exists
    if (-not (Test-Path $regPath)) {
        Write-Output "Registry key '$regPath' does not exist. Creating it."
        New-Item -Path $regPath -Force -Verbose
    }

    # Check and set each registry entry
    foreach ($entry in $registryEntries.GetEnumerator()) {
        $name = $entry.Key
        $desiredValue = $entry.Value

        # Check if the registry value exists
        $currentValue = Get-ItemProperty -Path $regPath -Name $name -ErrorAction SilentlyContinue

        if ($currentValue) {
            # If the value exists, check if it matches the desired value
            if ($currentValue.$name -ne $desiredValue) {
                Write-Output "Updating registry value '$name' at '$regPath' from '$($currentValue.$name)' to '$desiredValue'."
                Set-ItemProperty -Path $regPath -Name $name -Value $desiredValue -Verbose
            } else {
                Write-Output "Registry value '$name' at '$regPath' is already set to '$desiredValue'."
            }
        } else {
            # If the value does not exist, create it
            Write-Output "Registry value '$name' at '$regPath' does not exist. Creating and setting it to '$desiredValue'."
            New-ItemProperty -Path $regPath -Name $name -Value $desiredValue -PropertyType String -Force -Verbose
        }
    }

} catch {
    Write-Output "An error occurred: $_"
}

# End the transcript
Stop-Transcript
