### DocXTools Add-in Resiliency Finder
# Define the Registry path and value name
$registryPath = "HKCU:\Software\Microsoft\Office\16.0\Word\Resiliency\DoNotDisableAddinList"
$valueName = "Microsystems.DocXtoolsCompanion.Addin"

# Get the value of the specified Registry DWORD
$registryValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

if ($null -ne $registryValue) {
    # Output the Registry key location and value to a log file
    # $logEntry = "Registry Key $registryPath"
    # $logEntry += " | $valueName" + $registryValue.$valueName
    # $logEntry | Out-File -FilePath "C:\Temp\RegistryReport.txt" -Append
    Write-Output "Microsystems.DocXtoolsCompanion.Addin DWORD is already set to: $($registryValue.'Microsystems.DocXtoolsCompanion.Addin')"
    Exit 0
}
else {
    Write-Output "Remediation needed. DocXTools Word Addin resiliency not established!"
    Exit 1
}