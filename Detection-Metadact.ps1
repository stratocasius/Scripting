### Metadact - Disabled Metadact Add-in Remediator 
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\ZMetadact Options"
$RegistryName = "LoadBehavior"
$DesiredValue = 2

$RegistryValue = Get-ItemProperty -Path $RegistryPath -Name $RegistryName

if ($null -ne $RegistryValue) {
    $CurrentValue = $RegistryValue.$RegistryName
    if ($CurrentValue -eq $DesiredValue) {
        Write-Host "The Registry DWORD value is already set to $DesiredValue."
        exit 0  # No remediation is required.
    } else {
        Write-Host "Metadact addin is Disabled. Dword is currently set to $CurrentValue"
        exit 1  # This exit code signals that a remediation is needed.
    }
} else {
    Write-Host "The Registry DWORD value does not exist."
    exit 1  # This exit code signals that a remediation is needed.
}