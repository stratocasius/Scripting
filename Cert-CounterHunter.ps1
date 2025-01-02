# Define the issuer CN to search for
$issuerCN = "jacksonlewis-JL-ICA-E01-CA"

# Get all certificates from the LocalMachine store
$certStorePath = "Cert:\LocalMachine\My"
$certs = Get-ChildItem -Path $certStorePath -Recurse

# Filter certificates with the specified issuer CN
$matchingCerts = $certs | Where-Object {
    $_.Issuer -match "CN=$issuerCN"
}

# Initialize an array to hold the output strings for each certificate
$outputLines = @()

# Iterate over each matching certificate and construct its output string
foreach ($cert in $matchingCerts) {
    # Attempt to extract the template name from the certificate
    $templateExtension = $cert.Extensions | Where-Object { $_.Oid.FriendlyName -eq "Certificate Template Information" }
    if ($templateExtension) {
        $templateName = [regex]::Match($templateExtension.Format(0), 'Template=([\w\s]+)\(').Groups[1].Value.Trim()
    } else {
        $templateName = "N/A"  # Template information not found
    }

    # Construct the output string for this certificate
    $outputLines += "Certificate Name: $($cert.Subject); Template: $templateName"
}

# Combine all output strings into a single line
$singleLineOutput = $outputLines -join " | "

# Output the count and all certificate details on a single line
Write-Output "Count: $($matchingCerts.Count) | $singleLineOutput"
