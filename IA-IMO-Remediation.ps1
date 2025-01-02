# Define registry path, value name, and expected value
$registryPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Resiliency\DoNotDisableAddinList"
$valueName = "LexisNexis.InterAction.Outlook2016.AddIn"
$expectedValue = 1
$logFile = "C:\Windows\temp\IMO-AddinRemediation.log"

# Check if the registry value exists and its data matches the expected value
if (Test-Path $registryPath) {
    $currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $valueName

    if ($currentValue -ne $expectedValue) {
        # Change the registry value to the expected value
        Set-ItemProperty -Path $registryPath -Name $valueName -Value $expectedValue
        $logMessage = "$(Get-Date) - Registry value '$valueName' updated to '$expectedValue'"
    } else {
        $logMessage = "$(Get-Date) - Registry value '$valueName' is already set to '$expectedValue'"
    }
} else {
    # Create the registry path and set the value to the expected value if it doesn't exist
    New-Item -Path $registryPath -Force | Out-Null
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $expectedValue
    $logMessage = "$(Get-Date) - Registry path '$registryPath' created. Value '$valueName' set to '$expectedValue'"
}

# Log the output to the specified log file
Add-Content -Path $logFile -Value $logMessage
