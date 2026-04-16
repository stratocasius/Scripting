# Detection Script
# Exit 1 => Run remediation (missing/invalid tag OR 30+ days old)
# Exit 0 => Compliant (tag exists and < 30 days old)

$RegPath = "HKCU:\Software\Intune"
$RegName = "NotificationRemediation"

# Format: ddMMMyyyy (e.g., 23Jan2026)
$DateFormat = "ddMMMyyyy"
$Now = Get-Date

# Read existing value
try {
    $existing = (Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue).$RegName
} catch {
    $existing = $null
}

# Missing tag => remediate
if ([string]::IsNullOrWhiteSpace($existing)) {
    Write-Output "Non-compliant: Tag missing ($RegPath\$RegName)."
    exit 1
}

# Invalid format => remediate
try {
    $storedDate = [datetime]::ParseExact($existing, $DateFormat, $null)
} catch {
    Write-Output "Non-compliant: Tag value '$existing' not in expected format ($DateFormat)."
    exit 1
}

# Age check
$ageDays = ($Now.Date - $storedDate.Date).Days

if ($ageDays -ge 30) {
    Write-Output "Non-compliant: Tag is $ageDays days old (>= 30)."
    exit 1
}

Write-Output "Compliant: Tag is $ageDays days old (< 30)."
exit 0