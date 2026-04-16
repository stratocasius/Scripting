# Intune Detection: Report last credential provider (friendly name + GUID + username)
# Exit 1 if provider is a "password" provider (password-like GUIDs list)

$ErrorActionPreference = 'SilentlyContinue'

# Registry path
$reg = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI'

# Read provider GUID
$p = (Get-ItemProperty -Path $reg -Name LastLoggedOnProvider -ErrorAction SilentlyContinue).LastLoggedOnProvider

# Resolve username: prefer display name, else fallback to LastLoggedOnUser
$u = (Get-ItemProperty -Path $reg -Name LastLoggedOnDisplayName -ErrorAction SilentlyContinue).LastLoggedOnDisplayName
if (-not $u) { $u = (Get-ItemProperty -Path $reg -Name LastLoggedOnUser -ErrorAction SilentlyContinue).LastLoggedOnUser }
if (-not $u) { $u = 'Unknown' }

# Known provider GUIDs -> Friendly name
$known = @{
    '{D6886603-9D2F-4EB2-B667-1971041FA96B}' = 'Windows Hello (Biometric/PIN)'
    '{8FD7E19C-3BF7-489B-A72C-846AB3678C96}' = 'Smart Card'
    '{25CBB996-92ED-457E-B28C-4774084BD562}' = 'Username/Password'
    '{D27C3481-5A1C-45B2-8AAA-C20EBBE8229E}' = 'PIN Credential Provider'
    '{E951DC20-5A22-401B-8E43-3FCC5FBB9EE8}' = 'Picture Password'
    '{3E4E28CD-71D1-4FD4-A0B1-4F6C45F75FCA}' = 'Microsoft Account'
    '{DABC6C3F-9B3C-4C6A-8DC0-0804C9520E48}' = 'Password Reset Provider'
    '{25CA8579-1BD8-469c-B9FC-6AC45A161C18}' = 'PanV2CredProv'
    '{cb69481e-8ff7-4039-93ec-0a2729a154a8}' = 'YubiKey 5 (USB-A, No NFC)'
    '{60B78E88-EAD8-445C-9CFD-0B87F74EA6CD}' = 'Password Provider'   # built-in password provider
}

# Normalize provider GUID to upper-case curly-braced format if present
if ($p) { $p = $p.ToUpper() }

# Resolve friendly name
if ($p -and $known.ContainsKey($p)) {
    $friendly = $known[$p]
} elseif ($p) {
    # Try to read provider registration display name
    $provReg = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\$p"
    if (Test-Path $provReg) {
        try { $friendly = (Get-ItemProperty -Path $provReg -ErrorAction Stop).'(Default)' } catch { $friendly = $p }
    } else {
        $friendly = $p
    }
}
else {
    $friendly = 'NoneRecorded'
    $p = 'None'
}

# Define which GUIDs we treat as "password-like" (cause exit 1)
$passwordGuids = @(
    '{60B78E88-EAD8-445C-9CFD-0B87F74EA6CD}', # built-in Password Provider
    '{25CBB996-92ED-457E-B28C-4774084BD562}', # Username/Password (env)
    '{DABC6C3F-9B3C-4C6A-8DC0-0804C9520E48}'  # Password Reset Provider (optional)
) | ForEach-Object { $_.ToUpper() }

# Output a concise result for Intune
Write-Output ("{0}|{1}|{2}" -f $friendly, $p, $u)

# Exit non-compliant if provider is password-like
if ($p -and ($passwordGuids -contains $p)) {
    exit 1
} else {
    exit 0
}
