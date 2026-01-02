# Define registry path and value
$RegistryPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\Spelling"
$RegistryName = "Check"
$DesiredValue = 1
# Generate log file path in the user's home directory
$logFilePath = "C:\programdata\Microsoft\IntuneManagementExtension\Logs\AlwaysCheckBeforeSending-Remediation.log"
# Start transcript for logging
Start-Transcript -Path $logFilePath

# Check if the registry value exists and its value
$CurrentValue = (Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction SilentlyContinue).$RegistryName

if ($CurrentValue -ne $DesiredValue) {
    # Set the registry value to the desired value
    Write-Output "Registry value is incorrect or missing. Setting it to $DesiredValue..."
    ## Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $DesiredValue -Force
    Exit 1
} else {
    Write-Output "Change DWORD value is already set to $DesiredValue. No changes needed."
    Exit 0
}
Stop-Transcript