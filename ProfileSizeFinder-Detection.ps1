# Largest User Profile Size Detection (Windows 11 / Intune detection)
# Compliant: largest profile < 75 GB  -> exit 0
# Non-compliant (With issues): >= 75 GB -> exit 1

[CmdletBinding()]
param(
    [int]$ThresholdGB = 75
)

$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference    = 'SilentlyContinue'

# Folders under C:\Users to exclude from consideration
$excludeNames = @(
    'All Users', 'Default', 'Default User', 'Public', 'DefaultAppPool'
)

$usersRoot = Join-Path $env:SystemDrive 'Users'

if (-not (Test-Path -LiteralPath $usersRoot)) {
    Write-Host "Users root not found at $usersRoot. Treating as compliant."
    exit 0
}

# Use ROBOCOPY to measure directory size quickly and avoid counting junctions (/XJ).
function Get-DirectorySizeBytes {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return 0 }

    # Destination can be any throwaway path; /L ensures nothing is copied.
    $dest = Join-Path $env:TEMP 'robocopy_size_dummy'
    $output = & robocopy $Path $dest /L /BYTES /E /XJ /R:0 /W:0 2>$null | Out-String

    # Parse the "Bytes :" line (en-US). If parsing fails, return 0.
    if ($output -match 'Bytes\s*:\s*([\d,]+)') {
        return [int64](($matches[1]) -replace ',','')
    }
    return 0
}

# Gather candidate profile folders
$profileDirs = Get-ChildItem -LiteralPath $usersRoot -Directory -Force |
    Where-Object { $excludeNames -notcontains $_.Name }

if (-not $profileDirs) {
    Write-Host "No user profiles detected under $usersRoot (excluding system profiles). Treating as compliant."
    exit 0
}

$largest = $null
foreach ($dir in $profileDirs) {
    $bytes = Get-DirectorySizeBytes -Path $dir.FullName
    $obj = [PSCustomObject]@{
        Name  = $dir.Name
        Path  = $dir.FullName
        Bytes = $bytes
        GB    = [math]::Round($bytes / 1GB, 2)
    }
    if (-not $largest -or $obj.Bytes -gt $largest.Bytes) {
        $largest = $obj
    }
}

if (-not $largest) {
    Write-Host "Unable to determine largest profile. Treating as compliant."
    exit 0
}

# Output a clear, single-line status for Intune logs
Write-Host ("LargestProfileName='{0}'; Path='{1}'; SizeGB={2}; ThresholdGB={3}" -f `
    $largest.Name, $largest.Path, $largest.GB, $ThresholdGB)

# Compliance decision
if ($largest.GB -ge $ThresholdGB) {
    # With issues
    exit 1
} else {
    # Compliant
    exit 0
}
