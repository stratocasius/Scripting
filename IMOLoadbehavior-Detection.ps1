### ndMail Outlook Addin - Load Behavior Detection set to 3(all enabled)
# Define the registry path and value name
$RegistryPath = "HKCU:\Software\Microsoft\Office\Outlook\Addins\LexisNexis.InterAction.Outlook2016.AddIn"
$RegistryName = "LoadBehavior"
$DesiredValue = "3"

$RegistryValue = Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction SilentlyContinue

if ($null -ne $RegistryValue) {
    $CurrentValue = $RegistryValue.$RegistryName
    if ($CurrentValue -eq $DesiredValue) {
        Write-Host "IMO Addin DWORD value is currently set to $DesiredValue."
        exit 0  # No remediation is required.
    } else {
        Write-Host "IMO addin is Disabled and set to $CurrentValue. Remediation needed"
        exit 1  # This exit code signals that a remediation is needed.
    }
} else {
    Write-Host "The registry DWORD value does not exist. IMO not installed"
    exit 0 
}