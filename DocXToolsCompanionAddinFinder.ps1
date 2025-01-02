# Define the Registry path and value name
$registryPath = "HKLM:\SOFTWARE\Microsoft\Office\Word\Addins\Microsystems.DocXtoolsCompanion.AddIn"
$valueName = "Loadbehavior"

# Get the value of the specified Registry DWORD
$registryValue = Get-ItemProperty -Path $registryPath -Name $valueName

if ($null -ne $registryValue) {
    # Output the Registry key location and value to a log file
    # $logEntry = "Registry Key $registryPath"
    # $logEntry += " | $valueName" + $registryValue.$valueName
    # $logEntry | Out-File -FilePath "C:\Temp\RegistryReport.txt" -Append
    Write-Output "$($registryValue.PSChildName) $($registryValue.LoadBehavior)"
}
else {
    Write-Output "DocXTools Addin for Word not found!"
}