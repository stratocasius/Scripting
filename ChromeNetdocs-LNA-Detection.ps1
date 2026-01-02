$regKey = 'HKLM:\SOFTWARE\Policies\Google\Chrome\LocalNetworkAccessAllowedForUrls'
$regValueName = '1'
$expectedValue = 'https://vault.netvoyage.com/'

try {
    if (-not (Test-Path $regKey)) {
        Write-Output "Registry key not found: $regKey"
        exit 1
    }

    $value = (Get-ItemProperty -Path $regKey -Name $regValueName -ErrorAction SilentlyContinue).$regValueName
    if ($null -eq $value) {
        Write-Output "Registry value '$regValueName' not found under $regKey"
        exit 1
    }

    if ($value -ne $expectedValue) {
        Write-Output "Registry value mismatch. Found '$value' but expected '$expectedValue'"
        exit 1
    }

    Write-Output "Chrome Local Network Access setting found and correct set to 1 = http://vault.netvoyage.com."
    exit 0
}
catch {
    Write-Output "Error checking registry: $($_.Exception.Message)"
    exit 1
}
