# Define the registry path and value details
$logFilePath = "C:\Windows\Temp\MetadactLoadBehavior-Remediation.log"  # Path to the log file
$registryPath = "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\ZMetadact Options"
$valueName = "LoadBehavior"
$expectedValue = 3
# Check if the registry value exists and has the expected value
$currentValue = Get-ItemPropertyValue -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue
if ($currentValue -eq $expectedValue) {
    Write-Output "The registry value '$valueName' under '$registryPath' is already set to '$expectedValue'. No action needed."
Exit 0
} else {
    Exit 1
}