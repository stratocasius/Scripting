### Hello Status Finder - Detection script: 07/16/2025
# Generate timestamp for log file
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$logFilePath = "$env:LOCALAPPDATA\Temp\HelloStatus-Transcript.log"

# Start transcript
Start-Transcript -Path $logFilePath

# Define logon registry key and value
$logonKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI"
$lastProviderValue = "LastLoggedOnProvider"

Write-Host "=== Credential Provider Summary ==="

# Step 1: Last Used Credential Provider
if (Test-Path $logonKey) {
    try {
        $lastProvider = Get-ItemProperty -Path $logonKey -Name $lastProviderValue -ErrorAction Stop | Select-Object -ExpandProperty $lastProviderValue
        Write-Output "`nLast used credential provider GUID: $lastProvider"

        # Known credential provider mappings
        $knownProviders = @{
            '{D6886603-9D2F-4EB2-B667-1971041FA96B}' = 'Windows Hello (PIN)'
            '{D27C3481-5A1C-45B2-8AAA-C20EBBE8229E}' = 'PIN Credential Provider'
            '{8FD7E19C-3BF7-489B-A72C-846AB3678C96}' = 'Smart Card'
            '{25CBB996-92ED-457E-B28C-4774084BD562}' = 'Username/Password'
            '{3E4E28CD-71D1-4FD4-A0B1-4F6C45F75FCA}' = 'Microsoft Account'
            '{DABC6C3F-9B3C-4C6A-8DC0-0804C9520E48}' = 'Password Reset Provider'
            '{25CA8579-1BD8-469c-B9FC-6AC45A161C18}' = 'PanV2CredProv'
            '{8AF662BF-65A0-4D0A-A540-A338A999D36F}' = "FaceID"
            '{44E2ED41-48C7-4712-A3C3-250C5E6D5D84}' = "DUO for Windows"
        }

        if ($knownProviders.ContainsKey($lastProvider)) {
            Write-Output "Credential Provider Name: $($knownProviders[$lastProvider])"
        } else {
            Write-Output "Credential Provider Name: Unknown or third-party"
        }

    } catch {
        Write-Output "Could not read LastLoggedOnProvider: $_"
    }
} else {
    Write-Output "Credential Provider registry key not found."
}

# Step 2: Check WHfB provisioning status
Write-Host "`n=== Windows Hello for Business Enrollment Status ==="
$whfbKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\TestHooks"

if (Test-Path $whfbKey) {
    $whfbReg = Get-ItemProperty -Path $whfbKey
    $helloStatus = $whfbReg.IsWindowsHelloConfigured

    if ($helloStatus -eq 1) {
        Write-Output "Windows Hello for Business is provisioned/enrolled: YES"
    } else {
        Write-Output "Windows Hello for Business is provisioned/enrolled: NO"
    }
} else {
    Write-Output "WHfB TestHooks registry key not found."
}

# Step 3: Check for enabled Hello modalities
Write-Host "`n=== Windows Hello Modalities Enabled ==="

# Biometric Service (Face/Fingerprint)
$bioSvc = Get-Service -Name "WbioSrvc" -ErrorAction SilentlyContinue
if ($bioSvc -and $bioSvc.Status -eq 'Running') {
    Write-Output "Biometric Services: Running"
} else {
    Write-Output "Biometric Services: Not running or unavailable"
}

# Dynamic Lock (Bluetooth proximity unlock)
$dynLockKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
$dynEnabled = $null
if (Test-Path $dynLockKey) {
    $dynEnabled = (Get-ItemProperty -Path $dynLockKey -Name EnableGoodbye -ErrorAction SilentlyContinue).EnableGoodbye
    if ($dynEnabled -eq 1) {
        Write-Output "Dynamic Lock (Bluetooth proximity unlock): Enabled"
    } else {
        Write-Output "Dynamic Lock (Bluetooth proximity unlock): Disabled"
    }
} else {
    Write-Output "Dynamic Lock registry key not found (likely not configured)"
}

# PIN Logon policy
$pinKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$pinEnabled = $null
if (Test-Path $pinKey) {
    $pinEnabled = (Get-ItemProperty -Path $pinKey -Name AllowDomainPINLogon -ErrorAction SilentlyContinue).AllowDomainPINLogon
    if ($pinEnabled -eq 1) {
        Write-Output "PIN sign-in: Enabled by policy"
    } else {
        Write-Output "PIN sign-in: Disabled or not configured"
    }
} else {
    Write-Output "PIN policy registry not found."
}
# Stop transcript
Stop-Transcript