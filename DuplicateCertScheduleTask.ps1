# Get all machine certificates
$certs = Get-ChildItem -Path cert:\LocalMachine\My

# Group certificates by thumbprint
$dupCerts = $certs | Group-Object -Property Thumbprint | Where-Object { $_.Count -gt 1 }

# Delete duplicate certificates except for the first one in each group
foreach ($group in $dupCerts) {
    $group.Group | Select-Object -Skip 1 | ForEach-Object {
        $thumbprint = $_.Thumbprint
        Write-Host "Deleting duplicate certificate with thumbprint $thumbprint"
        Remove-Item -Path "cert:\LocalMachine\My\$thumbprint" -Force -Confirm:$false -WhatIf -Verbose
    }
}
