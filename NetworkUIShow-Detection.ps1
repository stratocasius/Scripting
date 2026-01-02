# Define registry path and value name
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$ValueName = "DontDisplayNetworkSelectionUI"
$DesiredValue = 0

try {
    # Check if the registry path exists
    if (-not (Test-Path $RegPath)) {
        Write-Output "Registry path not found. Creating it..."
        New-Item -Path $RegPath -Force | Out-Null
    }

    # Get the current DWORD value (if it exists)
    $currentValue = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $ValueName -ErrorAction SilentlyContinue

    if ($null -ne $currentValue) {
        if ($currentValue -eq $DesiredValue) {
            Write-Output "Compliant: $ValueName is already set to $DesiredValue."
            exit 0
        } else {
            Write-Output "Non-compliant: $ValueName is set to $currentValue."
            ## Set-ItemProperty -Path $RegPath -Name $ValueName -Value $DesiredValue -Type DWord
            ### Write-Output "$ValueName has been remediated to $DesiredValue."
            exit 0
        }
    } else {
        Write-Output "$ValueName not found."
        ## New-ItemProperty -Path $RegPath -Name $ValueName -Value $DesiredValue -PropertyType DWord -Force | Out-Null
        ## Write-Output "$ValueName created and set to $DesiredValue."
        exit 0
    }
}
catch {
    Write-Output "An error occurred: $_"
    exit 1
}
