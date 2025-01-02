function Get-FilteredCertificates {
    param (
        [string]$templateName
    )
    Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object {
        $_.Extensions | Where-Object {
            ($_.Oid.FriendlyName -eq 'Certificate Template Information') -and ($_.Format(0) -match $templateName)
        }
    }
}

$templateNames = @("1.3.6.1.4.1.311.21.8.12699277.13079172.10503332.10842942.11634168.37.11583287.4821995", "1.3.6.1.4.1.311.21.8.12699277.13079172.10503332.10842942.11634168.37.6753690.1421945", "1.3.6.1.4.1.311.21.8.12699277.13079172.10503332.10842942.11634168.37.9942855.2680763")

foreach ($templateName in $templateNames) {
    try {
        $certificates = Get-FilteredCertificates -templateName $templateName

        while ($certificates.Count -gt 1) {
            $oldestCertificate = $certificates | Sort-Object -Property NotAfter | Select-Object -First 1
            $thumbPrint = $oldestCertificate.ThumbPrint

            if ($thumbPrint) {
                Remove-Item "Cert:\LocalMachine\My\$thumbPrint"
                Write-Host "Deleted oldest certificate with thumbprint: $thumbPrint for template $templateName"
            }

            $certificates = Get-FilteredCertificates -templateName $templateName
        }
    } catch {
        Write-Host "An error occurred for template $templateName : $_"
        exit 1
    }
}

exit 0
