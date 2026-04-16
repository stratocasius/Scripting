# Intune Detection Script - Bluetooth Core Version (Intel / Realtek mapping)
# Exit 0 = Compliant
# Exit 1 = Non-compliant

$ErrorActionPreference = "SilentlyContinue"

$MinimumVersion = [version]"5.4"

function Get-PnpDevicesSafe {
    param(
        [string]$ClassName
    )

    try {
        if (Get-Command Get-PnpDevice -ErrorAction SilentlyContinue) {
            return @(Get-PnpDevice -Class $ClassName -ErrorAction SilentlyContinue)
        }
    }
    catch { }

    return @()
}

function Get-AdapterNameCandidates {
    $names = @()

    try {
        # Bluetooth radios / endpoints
        $bt = Get-PnpDevicesSafe -ClassName "Bluetooth"
        foreach ($d in $bt) {
            if ($d.FriendlyName) { $names += $d.FriendlyName }
            if ($d.Name) { $names += $d.Name }
        }
    }
    catch { }

    try {
        # Wireless adapters often carry the actual chipset family in the Wi-Fi adapter name
        $net = Get-PnpDevicesSafe -ClassName "Net"
        foreach ($d in $net) {
            if ($d.FriendlyName) { $names += $d.FriendlyName }
            if ($d.Name) { $names += $d.Name }
        }
    }
    catch { }

    $names | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
}

function Get-BluetoothCoreVersionFromName {
    param(
        [string[]]$Names
    )

    # Order matters: check the most specific / newest families first
    $map = @(
        @{ Pattern = 'BE201';          Version = '5.4'; Family = 'Intel BE201' }
        @{ Pattern = 'BE200';          Version = '5.4'; Family = 'Intel BE200' }
        @{ Pattern = 'AX211';          Version = '5.4'; Family = 'Intel AX211' }
        @{ Pattern = 'AX201';          Version = '5.2'; Family = 'Intel AX201' }
        @{ Pattern = 'AX210';          Version = '5.2'; Family = 'Intel AX210' }
        @{ Pattern = 'AX411';          Version = '5.2'; Family = 'Intel AX411' }

        @{ Pattern = 'RTL8821CE';      Version = '5.0'; Family = 'Realtek RTL8821CE' }
        @{ Pattern = 'RTL8821CS';      Version = '4.2'; Family = 'Realtek RTL8821CS' }
        @{ Pattern = 'RTL8821CU';      Version = '4.2'; Family = 'Realtek RTL8821CU' }
        @{ Pattern = 'RTL8821AE';      Version = '4.0'; Family = 'Realtek RTL8821AE' }
        @{ Pattern = 'RTL8821AU';      Version = '4.0'; Family = 'Realtek RTL8821AU' }

        @{ Pattern = 'RTL8822BEH-?VR'; Version = '4.1'; Family = 'Realtek RTL8822BEH-VR' }
        @{ Pattern = 'RTL8822BE';      Version = '4.2'; Family = 'Realtek RTL8822BE' }
        @{ Pattern = 'RTL8822BS';      Version = '4.1'; Family = 'Realtek RTL8822BS' }
        @{ Pattern = 'RTL8822BU';      Version = '4.1'; Family = 'Realtek RTL8822BU' }
    )

    foreach ($name in $Names) {
        foreach ($item in $map) {
            if ($name -match $item.Pattern) {
                return [PSCustomObject]@{
                    Family  = $item.Family
                    Version = [version]$item.Version
                    Source  = $name
                }
            }
        }
    }

    return $null
}

try {
    $names = Get-AdapterNameCandidates
    $match = Get-BluetoothCoreVersionFromName -Names $names

    if (-not $match) {
        $primary = if ($names.Count -gt 0) { $names[0] } else { "No Bluetooth/Wi-Fi adapter name found" }
        Write-Output "Unsupported chipset - $primary"
        exit 1
    }

    $display = "Bluetooth® Core $($match.Version.ToString()) technology"

    if ($match.Version -ge $MinimumVersion) {
        Write-Output "Compliant - $display"
        exit 0
    }
    else {
        Write-Output "Non-Compliant - $display"
        exit 1
    }
}
catch {
    Write-Output "Unsupported chipset - detection failed"
    exit 1
}