### Global Protect Duplicate Cert Detection
function Get-CertificateCount {
    param (
        [string]$templateName
    )
    $certificates = Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object {
        $_.Extensions | Where-Object {
            ($_.Oid.FriendlyName -eq 'Certificate Template Information') -and ($_.Format(0) -match $templateName)
        }
    }
    return $certificates.Count
}

$templateNames = @("1.3.6.1.4.1.311.21.8.12699277.13079172.10503332.10842942.11634168.37.11583287.4821995", "1.3.6.1.4.1.311.21.8.12699277.13079172.10503332.10842942.11634168.37.6753690.1421945", "1.3.6.1.4.1.311.21.8.12699277.13079172.10503332.10842942.11634168.37.9942855.2680763")
$outputResults = @()
$remediationRequired = $false

foreach ($templateName in $templateNames) {
    $certificateCount = Get-CertificateCount -templateName $templateName
    $outputResults += "$templateName : $certificateCount"

    if ($certificateCount -gt 1) {
        $remediationRequired = $true
    }
}

# Output results in a single line
Write-Output ($outputResults -join " || ")

# Exit code based on whether remediation is required
if ($remediationRequired) {
#    Write-Output "Remediation required"
    exit 1
} else {
#    Write-Output "Remediation not required"
    exit 0
}
