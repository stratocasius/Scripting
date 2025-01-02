# Define the registry key path and DWORD details
$registryKeyPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Resiliency\DoNotDisableAddinList"
$dwordName = "NetDocuments.ndMail.OutlookAddIn"
$dwordValue = 1
    # Create the DWORD value under the registry key
       New-Item -Path $registryKeyPath -ErrorAction SilentlyContinue
       New-ItemProperty -Path $registryKeyPath -Name $dwordName -PropertyType DWORD -Value $dwordValue -Force
       Write-Output "ndMail Outlook Add-in DWORD valued 1 created at '$registryKeyPath' on $(Get-Date)."