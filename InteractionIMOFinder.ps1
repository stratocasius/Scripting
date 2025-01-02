# Define the Registry path and value name
$registryPath = "HKCU:\Software\Microsoft\Office\Outlook\Addins\LexisNexis.InterAction.Outlook2016.AddIn"
$valueName = "LoadBehavior"

# Get the value of the specified Registry DWORD
$registryValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

if ($null -ne $registryValue) {
    # Output the Registry key location and value to a log file
    # $logEntry = "Registry Key $registryPath"
    # $logEntry += " | $valueName" + $registryValue.$valueName
    # $logEntry | Out-File -FilePath "C:\Temp\RegistryReport.txt" -Append
    Write-Output "$($registryValue.LoadBehavior) $($registryValue.PSChildName)"
}
else {
    Write-Output "Interaction IMO for Outlook dword not found!"
}