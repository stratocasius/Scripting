# Define the registry path and the desired DWORD name and value
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
$dwordName = "EnableMDNS"
$dwordValue = 0

# Check if the registry path exists
if (-not (Test-Path -Path $registryPath)) {
    # If the path does not exist, create it
    New-Item -Path $registryPath -Force | Out-Null
}

# Check if the DWORD exists and has the correct value
$existingValue = (Get-ItemProperty -Path $registryPath -Name $dwordName -ErrorAction SilentlyContinue).$dwordName

if ($existingValue -ne $dwordValue) {
    # If the DWORD does not exist or has a different value, create or update it
    New-ItemProperty -Path $registryPath -Name $dwordName -Value $dwordValue -PropertyType DWord -Force | Out-Null
    Write-Output "Registry value 'EnableMDNS' now set to 0."
    Exit 1
} else {
    Write-Output "EnableMDNS is found and already set to 0."
    Exit 0
}