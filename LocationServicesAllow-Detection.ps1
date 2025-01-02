$regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\"
$valueName = "Value"
$desiredValue = "Allow"

# Check if the registry key exists
if (Test-Path $regPath) {
    # Get the current value of the registry key
    $currentValue = Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue

    if ($currentValue -ne $null) {
        # Compare the current value with the desired value
        if ($currentValue.$valueName -ne $desiredValue) {
            # Remediate by setting the value to the desired value
           # Set-ItemProperty -Path $regPath -Name $valueName -Value $desiredValue
            Write-Output "Remediation Needed!!! Value needs set to Allow."
            Exit 1
        } else {
            Write-Output "Value already set to Allow"
            Exit 0
        }
    } else {
        Write-Output "The value name does not exist in the specified registry path."
        Exit 1
    }
} else {
    Write-Output "The specified registry path does not exist."
    Exit 1
}