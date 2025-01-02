# Define the registry path and value details
$logFilePath = "C:\Windows\Temp\MetadactLoadBehavior-Remediation.log"  # Path to the log file
$registryPath = "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\ZMetadact Options"
$valueName = "LoadBehavior"
$expectedValue = 3

Set-ItemProperty -Path $registryPath -Name $valueName -Value $expectedValue -Type DWORD -Force
$logMessageFixed = "Metadact's Addin LoadBehavior DWORD was remediated to value of 3 located in registry path HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\ZMetadact Options\ remediated on $(Get-Date)"
$logMessageFixed | Out-File -FilePath $logFilePath -Append
Write-Output "Metadact's Addin LoadBehavior DWORD was remediated to value of 3 on $(Get-Date)"

