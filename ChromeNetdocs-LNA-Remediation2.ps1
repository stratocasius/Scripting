<#
Remediation for Intune Proactive Remediations
- Ensures Chrome policy values for LocalNetworkAccessAllowedForUrls are defined correctly
- Removes any undefined numeric values (extra or unexpected URLs)
- Outputs all results on a single line for Intune logging
#>

param(
    [string[]]$RequiredUrls = @(
        'https://vault.netvoyage.com',
        'https://lna-testing.notyetsecure.com/'
    ),
    [string]$RegistryPath = 'HKLM:\SOFTWARE\Policies\Google\Chrome\LocalNetworkAccessAllowedForUrls'
)

function New-ExpectedMap([string[]]$urls){
    $map = @{}
    for ($i = 0; $i -lt $urls.Count; $i++){
        $map["$($i+1)"] = $urls[$i]
    }
    return $map
}

$expectedMap = New-ExpectedMap $RequiredUrls
$expectedKeys = @($expectedMap.Keys)

$actions = @()

# Ensure key exists
if (-not (Test-Path -Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
    $actions += "CreatedKey"
}

# Create or update required values
foreach ($k in $expectedKeys | Sort-Object {[int]$_}) {
    $v = $expectedMap[$k]
    $currentVal = $null
    try { $currentVal = Get-ItemPropertyValue -Path $RegistryPath -Name $k -ErrorAction Stop } catch {}
    if ($currentVal -ne $v) {
        New-ItemProperty -Path $RegistryPath -Name $k -Value $v -PropertyType String -Force | Out-Null
        if ($null -eq $currentVal) { $actions += "Added:$k" } else { $actions += "Updated:$k" }
    }
}

# Remove undefined names or values
try {
    $existingProps = (Get-Item -Path $RegistryPath).Property | Where-Object { $_ -match '^\d+$' }
    foreach ($prop in $existingProps) {
        $currentVal = (Get-ItemPropertyValue -Path $RegistryPath -Name $prop -ErrorAction SilentlyContinue)
        $isUnexpectedName  = -not ($expectedKeys -contains $prop)
        $isUnexpectedValue = -not ($RequiredUrls -contains $currentVal)
        if ($isUnexpectedName -or $isUnexpectedValue) {
            Remove-ItemProperty -Path $RegistryPath -Name $prop -ErrorAction SilentlyContinue
            $actions += "Removed:$prop=$currentVal"
        }
    }
} catch {
    $actions += "CleanupError:$($_.Exception.Message)"
}

# Collect final summary of values
try {
    $finalVals = @()
    if (Test-Path $RegistryPath) {
        $finalVals = (Get-Item -Path $RegistryPath).Property | Where-Object { $_ -match '^\d+$' } |
                     Sort-Object {[int]$_} | ForEach-Object { Get-ItemPropertyValue -Path $RegistryPath -Name $_ }
    }
    $finalJoined = if ($finalVals.Count) { $finalVals -join ',' } else { 'NONE' }
} catch {
    $finalJoined = "ErrorReading"
}

# Emit exactly one line of output
Write-Output ("Actions={0}; FinalValues={1}" -f ($actions -join ','), $finalJoined)

exit 0
