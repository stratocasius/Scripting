### ndMail Outlook Add-in Resiliency Detection
# Define the Registry path and value name
$registryPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Resiliency\DoNotDisableAddinList"
$valueName = "NetDocuments.ndMail.OutlookAddIn"

# Get the value of the specified Registry DWORD
$registryValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

if ($null -ne $registryValue) {
    # Output the Registry key location and value to a log file
    # $logEntry = "Registry Key $registryPath"
    # $logEntry += " | $valueName" + $registryValue.$valueName
    # $logEntry | Out-File -FilePath "C:\Temp\RegistryReport.txt" -Append
    Write-Output "NetDocuments.ndMail.OutlookAddIn DWORD is already set to: $($registryValue.'ZMetadact Options')"
    Exit 0
}
else {
    Write-Output "Remediation needed. ndMail Addin resiliency not established!"
    Exit 1
}