# Define the thumbprint of the intermediate certificate
$thumbprint = "52b8ab154fb86ec90a8a2e8b208257ca9dd0dc32"

# Get the certificate by thumbprint
$certificate = Get-ChildItem -Path Cert:\LocalMachine\CA | Where-Object { $_.Thumbprint -eq $thumbprint }

if ($certificate) {
    # Display certificate information
    Write-Host "New ICA Found - Not After: $($certificate.NotAfter)"
}
else {
    Write-Host "Old Intermediate certificate with thumbprint found that expires 11/11/2023."
}

# You can add more remediation actions here if needed
# For example, you could remove the certificate or take other actions based on your requirements


