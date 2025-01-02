# Get certificates from the Personal store
$PersonalStore = Get-ChildItem -Path Cert:\CurrentUser\My

# Create an empty array to store certificate information
$CertificateInfo = @()

# Loop through each certificate in the Personal store
foreach ($cert in $PersonalStore) {
    $CertProperties = @{
        "Subject" = $cert.Subject
        "Issuer" = $cert.Issuer
        "Thumbprint" = $cert.Thumbprint
        "ValidFrom" = $cert.NotBefore
        "ValidTo" = $cert.NotAfter
    }
    $CertificateInfo += New-Object PSObject -Property $CertProperties
}

# Display the certificate information in the console
$CertificateInfo | Format-Table -AutoSize

Install-Module Microsoft.Graph.Intune -Scope AllUsers -Force -Verbose

