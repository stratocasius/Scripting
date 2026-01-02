### ndOffice M365 Enterprise Apps Addin disablement Detection - Load Behavior Detection set to 2(always disable)
# Define the registry path and value name
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Office\Excel\Addins\NetDocuments.Client.ExcelAddIn"
$RegistryName = "LoadBehavior"
$DesiredValue = "2"

$RegistryValue = Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction SilentlyContinue

if ($null -ne $RegistryValue) {
    $CurrentValue = $RegistryValue.$RegistryName
    if ($CurrentValue -eq $DesiredValue) {
        Write-Host "Excel ndOffice LoadBehavior DWORD value is currently set to $DesiredValue."
        exit 0  # No remediation is required.
    } else {
        Write-Host "Excel ndOffice LoadBehavior DWORD value is Enabled and set to $CurrentValue. Remediation needed"
        exit 1  # This exit code signals that a remediation is needed.
    }
} else {
    Write-Host "Excel ndOffice DWORD value does not exist. DocXTools not installed"
    exit 0  # This exit code signals that a remediation is needed.
}


#### If the installer is targeting all users on 64-bit Windows, it is recommended that it includes two registry entries, one under the HKEY_LOCAL_MACHINE\Software\Microsoft and one under the HKEY_LOCAL_MACHINE\Software\WOW6432Node\Microsoft hive. This is because it's possible for users to use either 32-bit or 64-bit versions of Office on the computer.
#### If the Installer is targeting the current user, it doesn't need to install to the WOW6432Node because the HKEY_CURRENT_USER\Software path is shared.