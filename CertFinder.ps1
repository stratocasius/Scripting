# Color-coded certificate expiration report
# 2026 = Red
# 2027 = Yellow
# >2027 = Default

$now = Get-Date
$cutoffDate = $now.AddYears(3)

$stores = @(
    "Cert:\CurrentUser\My",
    "Cert:\CurrentUser\Root",
    "Cert:\CurrentUser\CA",
    "Cert:\CurrentUser\TrustedPublisher",
    "Cert:\LocalMachine\My",
    "Cert:\LocalMachine\Root",
    "Cert:\LocalMachine\CA",
    "Cert:\LocalMachine\TrustedPublisher"
)

# Collect results
$results = foreach ($store in $stores) {
    if (Test-Path $store) {
        Get-ChildItem -Path $store -ErrorAction SilentlyContinue |
        Where-Object {
            $_.NotAfter -gt $now -and
            $_.NotAfter -le $cutoffDate
        } |
        ForEach-Object {
            [PSCustomObject]@{
                Store      = $store
                Name       = if ($_.FriendlyName) { $_.FriendlyName } else { $_.Subject }
                Issuer     = $_.Issuer
                Thumbprint = $_.Thumbprint
                Expiration = $_.NotAfter
            }
        }
    }
}

# Header
Write-Host ""
Write-Host ("{0,-45} {1,-35} {2,-42} {3,-42} {4,-12}" -f `
    "Store","Expiration","Name","Issuer","Thumbprint") -ForegroundColor Cyan
Write-Host ("-" * 180)

# Output with color coding
foreach ($cert in ($results | Sort-Object Expiration, Name)) {

    $year = $cert.Expiration.Year

    switch ($year) {
        2026 { $color = "Red" }
        2027 { $color = "Yellow" }
        default { $color = $null }
    }

    $line = "{0,-45} {1,-35} {2,-42} {3,-42} {4,-12}" -f `
        $cert.Store,
        ($cert.Name -replace "`r|`n"," "),
        ($cert.Issuer -replace "`r|`n"," "),
        $cert.Thumbprint,
        $cert.Expiration.ToString("yyyy-MM-dd")

    if ($color) {
        Write-Host $line -ForegroundColor $color
    }
    else {
        Write-Host $line
    }
}
