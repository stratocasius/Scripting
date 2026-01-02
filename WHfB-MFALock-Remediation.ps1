$log = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Hello-Detection.log"
New-Item -ItemType File -Path $log -Force | Out-Null

function Log {
    param($msg)
    Add-Content -Path $log -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg"
}

# Check if Windows Hello is enabled via policy
$enabled = $null
$keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork"

if (Test-Path $keyPath) {
    $prop = Get-ItemProperty -Path $keyPath
    if ($prop.PSObject.Properties.Name -contains "Enabled") {
        $enabled = $prop.Enabled
    }
}

Log "PassportForWork Policy Enabled = $enabled"

if ($enabled -eq 1) {
    Log "Windows Hello is already enabled. No remediation required."
    exit 0
} else {
    Log "Windows Hello is disabled or not configured. Remediation required."
    exit 1
}

##########################################################################################################
$log = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Hello-Remediation.log"
New-Item -ItemType File -Path $log -Force | Out-Null

function Log {
    param($msg)
    Add-Content -Path $log -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg"
}

# Enable Windows Hello for Business
$whfbKey = "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork"
if (-not (Test-Path $whfbKey)) {
    New-Item -Path $whfbKey -Force | Out-Null
}
Set-ItemProperty -Path $whfbKey -Name "Enabled" -Value 1 -Type DWord
Log "Enabled Windows Hello for Business via registry."

# Enable PIN sign-in (required for WHfB)
$pinKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
if (-not (Test-Path $pinKey)) {
    New-Item -Path $pinKey -Force | Out-Null
}
Set-ItemProperty -Path $pinKey -Name "AllowDomainPINLogon" -Value 1 -Type DWord
Log "Enabled domain PIN login."

# Ensure Biometric Services are enabled
$bioService = Get-Service -Name "WbioSrvc" -ErrorAction SilentlyContinue
if ($bioService -and $bioService.Status -ne 'Running') {
    Start-Service -Name "WbioSrvc"
    Log "Started Windows Biometric Service."
} elseif ($bioService) {
    Log "Windows Biometric Service already running."
} else {
    Log "Windows Biometric Service not found."
}

# Enable Biometrics via policy
$biometricKey = "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics"
if (-not (Test-Path $biometricKey)) {
    New-Item -Path $biometricKey -Force | Out-Null
}
Set-ItemProperty -Path $biometricKey -Name "Enabled" -Value 1 -Type DWord
Set-ItemProperty -Path $biometricKey -Name "FacialFeatures_Enabled" -Value 1 -Type DWord
Log "Biometric facial recognition enabled."

# Enable Dynamic Lock (Proximity via Bluetooth)
$lockKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
if (-not (Test-Path $lockKey)) {
    New-Item -Path $lockKey -Force | Out-Null
}
Set-ItemProperty -Path $lockKey -Name "EnableGoodbye" -Value 1 -Type DWord
Log "Dynamic lock (Bluetooth proximity) enabled."

# Additional Bluetooth support (optional check)
$btSupport = Get-Service -Name "bthserv" -ErrorAction SilentlyContinue
if ($btSupport -and $btSupport.Status -ne 'Running') {
    Start-Service -Name "bthserv"
    Log "Started Bluetooth Support Service."
}

Log "Windows Hello, PIN, Facial, and Proximity unlock have been enabled."
