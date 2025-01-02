# Define the registry path
$registryPath = "HKLM:\SOFTWARE\Duo Security\DuoCredProv"

# Assume no need for remediation initially
$needRemediation = $false

# Check for FailOpen value
$failOpen = Get-ItemProperty -Path $registryPath -Name "FailOpen" -ErrorAction SilentlyContinue
if (-not $failOpen -or $failOpen.FailOpen -ne 1) {
    $needRemediation = $true
}

# Check for OfflineAvailable value
$offlineAvailable = Get-ItemProperty -Path $registryPath -Name "OfflineAvailable" -ErrorAction SilentlyContinue
if (-not $offlineAvailable -or $offlineAvailable.OfflineAvailable -ne 0) {
    $needRemediation = $true
}

# Exit with code 1 if remediation is needed, 0 otherwise
if ($needRemediation) {
    Write-output "Fail Closed. Remediation required"
    exit 1
} else {
    Write-output "Fail Opened. No changes required"
    exit 0
}
################################################
#### Remediation
# Define the registry path
$registryPath = "HKLM:\SOFTWARE\Duo Security\DuoCredProv"

# Ensure FailOpen is set to 1
$failOpen = Get-ItemProperty -Path $registryPath -Name "FailOpen" -ErrorAction SilentlyContinue
if (-not $failOpen -or $failOpen.FailOpen -ne 1) {
    Set-ItemProperty -Path $registryPath -Name "FailOpen" -Value 1 -ErrorAction SilentlyContinue
    if (-not $?) {
        New-ItemProperty -Path $registryPath -Name "FailOpen" -Value 1 -PropertyType DWORD -ErrorAction SilentlyContinue
    }
}

# Ensure OfflineAvailable is set to 0
$offlineAvailable = Get-ItemProperty -Path $registryPath -Name "OfflineAvailable" -ErrorAction SilentlyContinue
if (-not $offlineAvailable -or $offlineAvailable.OfflineAvailable -ne 0) {
    Set-ItemProperty -Path $registryPath -Name "OfflineAvailable" -Value 0 -ErrorAction SilentlyContinue
    if (-not $?) {
        New-ItemProperty -Path $registryPath -Name "OfflineAvailable" -Value 0 -PropertyType DWORD -ErrorAction SilentlyContinue
    }
}
