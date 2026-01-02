<#
Detection for Intune Proactive Remediations.
- Checks HKLM:\SOFTWARE\Policies\Google\Chrome\LocalNetworkAccessAllowedForUrls
- Required items are numbered "1","2",... in the order listed in $RequiredUrls
- Returns failure if:
  * Any required index is missing or has a different URL (mismatch), OR
  * Any numeric entry exists whose URL is not in $RequiredUrls (undefined URL), OR
  * Any extra numeric entry exists beyond the defined indices (duplicate/extra)
- Prints exactly ONE line summarizing current values and status.
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
$expectedKeys = $expectedMap.Keys

# Gather current numeric props (Name/Value), sorted numerically
$currentPairs = @()
if (Test-Path -Path $RegistryPath) {
    try {
        $propNames = (Get-Item -Path $RegistryPath).Property | Where-Object { $_ -match '^\d+$' } | Sort-Object {[int]$_}
        foreach ($n in $propNames) {
            try {
                $v = Get-ItemPropertyValue -Path $RegistryPath -Name $n -ErrorAction Stop
                $currentPairs += @{ Name = $n; Value = [string]$v }
            } catch {}
        }
    } catch {}
}

# Build quick lookups
$currentByName = @{}
foreach ($p in $currentPairs) { $currentByName[$p.Name] = $p.Value }

# Checks
$missingOrMismatch = @()
foreach ($k in $expectedKeys) {
    if (-not $currentByName.ContainsKey($k)) {
        $missingOrMismatch += "missing:$k"
    } elseif ($currentByName[$k] -ne $expectedMap[$k]) {
        $missingOrMismatch += "mismatch:$k"
    }
}

# Undefined = any present URL not in the defined list
$definedUrlSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$RequiredUrls)
$undefinedUrls = @()
foreach ($p in $currentPairs) {
    if (-not $definedUrlSet.Contains($p.Value)) {
        $undefinedUrls += $p.Value
    }
}

# Extras = numeric names that are not defined indices (e.g., 3 when only 1..2 exist) OR duplicates
$extraNames = @()
foreach ($p in $currentPairs) {
    if (-not $expectedMap.ContainsKey($p.Name)) {
        $extraNames += $p.Name
    }
}

# Compliance logic
$compliant = ($missingOrMismatch.Count -eq 0) -and ($undefinedUrls.Count -eq 0) -and ($extraNames.Count -eq 0)

# Build one-line status
$valuesOnly = ($currentPairs | Sort-Object {[int]$_.Name}).Value
$valuesJoined = if ($valuesOnly.Count -gt 0) { $valuesOnly -join ', ' } else { 'NONE' }
$foundCount   = $valuesOnly.Count

$undefinedJoined = if ($undefinedUrls.Count -gt 0) { ($undefinedUrls | Select-Object -Unique) -join ', ' } else { 'NONE' }
$extrasJoined    = if ($extraNames.Count -gt 0) { ($extraNames | Select-Object -Unique | Sort-Object {[int]$_}) -join ',' } else { 'NONE' }
$mmJoined        = if ($missingOrMismatch.Count -gt 0) { ($missingOrMismatch -join ',') } else { 'NONE' }

Write-Output ("Found={0}; Values={1}; UndefinedURLs={2}; ExtraIndices={3}; MissingOrMismatch={4}; Compliance={5}" -f `
    $foundCount, $valuesJoined, $undefinedJoined, $extrasJoined, $mmJoined, $compliant)

if ($compliant) { exit 0 } else { exit 1 }
