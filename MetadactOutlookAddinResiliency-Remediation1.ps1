# Define the registry key path and DWORD details
$registryKeyPath = "HKCU:\Software\Microsoft\Office\16.0\Word\Resiliency\DoNotDisableAddinList"
$dwordName = "Microsystems.DocXtoolsCompanion.Addin"
$dwordValue = 1
    # Create the DWORD value under the registry key
       New-ItemProperty -Path $registryKeyPath -Name $dwordName -PropertyType DWORD -Value $dwordValue -Force | Out-Null
       Write-Output "DocXTools Addin DWORD valued 1 created at '$registryKeyPath' on $(Get-Date)."