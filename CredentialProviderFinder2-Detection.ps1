### Credential Provider Finder - 07/11/2025
# Define path and registry value
$logonKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI"
$lastProviderValue = "LastLoggedOnProvider"

# Check if the value exists
if (Test-Path $logonKey) {
    try {
        $lastProvider = Get-ItemProperty -Path $logonKey -Name $lastProviderValue -ErrorAction Stop | Select-Object -ExpandProperty $lastProviderValue

        Write-Output "Last used credential provider GUID: $lastProvider"

        # Optional: map to known provider name
        $knownProviders = @{
            '{D6886603-9D2F-4EB2-B667-1971041FA96B}' = 'Windows Hello (Biometric/PIN)'
            '{8FD7E19C-3BF7-489B-A72C-846AB3678C96}' = 'Smart Card'
            '{25CBB996-92ED-457E-B28C-4774084BD562}' = 'Username/Password'
            '{D27C3481-5A1C-45B2-8AAA-C20EBBE8229E}' = 'PIN Credential Provider'
            '{E951DC20-5A22-401B-8E43-3FCC5FBB9EE8}' = 'Picture Password'
            '{3E4E28CD-71D1-4FD4-A0B1-4F6C45F75FCA}' = 'Microsoft Account'
            '{DABC6C3F-9B3C-4C6A-8DC0-0804C9520E48}' = 'Password Reset Provider'
            '{25CA8579-1BD8-469c-B9FC-6AC45A161C18}' = 'PanV2CredProv'
            '{cb69481e-8ff7-4039-93ec-0a2729a154a8}' = 'YubiKey 5 (USB-A, No NFC)'
        }

        if ($knownProviders.ContainsKey($lastProvider)) {
            Write-Output "Credential Provider Name: $($knownProviders[$lastProvider])"
        } else {
            Write-Output "Credential Provider Name: Unknown (not in known list)"
        }

    } catch {
        Write-Output "Could not read the LastLoggedOnProvider value. $_"
    }
} else {
    Write-Output "Credential Provider registry key not found."
}
