### Metadact Outlook Addin - Load Behavior Detection set to 3(all enabled)
# Define the registry path and value name
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\ZMetadact Options\"
$RegistryName = "LoadBehavior"
$DesiredValue = "3"

$RegistryValue = Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction SilentlyContinue

if ($null -ne $RegistryValue) {
    $CurrentValue = $RegistryValue.$RegistryName
    if ($CurrentValue -eq $DesiredValue) {
        Write-Host "LoadBehavior DWORD is already set to $DesiredValue."
        exit 0  # No remediation is required.
    } else {
        Write-Host "Metadact addin is Disabled and set to $CurrentValue. Remediation needed"
        exit 1  # This exit code signals that a remediation is needed.
    }
} else {
    Write-Host "The Registry DWORD value does not exist. Metadact not installed"
    exit 0  # This exit code signals that no remediation is needed.
}