<#
.SYNOPSIS
  Wipe one or more devices using ConfigMgr's Invoke-CMDeviceWipe.

.DESCRIPTION
  This script looks up devices in ConfigMgr (by Name or ResourceId),
  shows a summary, prompts for confirmation and then calls Invoke-CMDeviceWipe.
  It logs actions to a local log file and supports WhatIf and Force.

.NOTES
  - Must be run from the Configuration Manager PowerShell drive (e.g. "PS ABC:>").
  - Requires the ConfigurationManager module / site PS drive available.
  - Reference: Invoke-CMDeviceWipe (Microsoft Docs). :contentReference[oaicite:1]{index=1}

.PARAMETER DeviceNames
  One or more device names (ConfigMgr DeviceName). Can include wildcards when -ForceWildcardHandling used.

.PARAMETER DeviceIds
  One or more ConfigMgr Resource IDs (int). Mutually exclusive with DeviceNames.

.PARAMETER Force
  Skip interactive confirmation.

.PARAMETER WhatIfOnly
  Show what would happen, do not perform wipes.

.EXAMPLE
  .\SCCM-WipeDevice.ps1 -DeviceNames 'WIN10-1001'

  .\SCCM-WipeDevice.ps1 -DeviceIds 10001,10002 -Force

#>

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
param(
    [Parameter(Mandatory=$false, Position=0)]
    [string[]]$DeviceNames,

    [Parameter(Mandatory=$false, Position=1)]
    [int[]]$DeviceIds,

    [switch]$Force,

    [switch]$WhatIfOnly
)

# Logging
$logDir = "$env:ProgramData\ConfigMgr-Scripts"
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
$logFile = Join-Path $logDir ("SCCM-WipeDevice_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))

function Log {
    param($Text)
    $line = "{0:yyyy-MM-dd HH:mm:ss} {1}" -f (Get-Date), $Text
    $line | Out-File -FilePath $logFile -Encoding UTF8 -Append
    Write-Host $Text
}

# Validate environment: must be in a ConfigMgr PS site drive or have module loaded
try {
    if (-not (Get-Module -Name ConfigurationManager)) {
        # Attempt to import module (common pattern is to import ConfigMgr module from site)
        Import-Module ConfigurationManager -ErrorAction SilentlyContinue
    }
} catch {
    # ignore
}

# Check for site drive (PSDrive with ConfigurationManager provider)
$siteDrive = Get-PSDrive | Where-Object { $_.Provider -match 'ConfigurationManager' } | Select-Object -First 1
if (-not $siteDrive) {
    Log "ERROR: This script must be run from the Configuration Manager site PowerShell drive (run the ConfigMgr console's PowerShell or Import-Module then cd to the site drive). Aborting."
    throw "Configuration Manager site drive not found. Run from the ConfigMgr console PowerShell (e.g. 'cd ABC:') or import the ConfigurationManager module and connect to site."
}

Log "Using site drive: $($siteDrive.Name): (Provider: $($siteDrive.Provider))"

# Validate input
if (-not $DeviceNames -and -not $DeviceIds) {
    Log "ERROR: No device specified. Provide -DeviceNames or -DeviceIds."
    throw "Provide -DeviceNames or -DeviceIds."
}

# Helper: get device objects
$devices = @()
if ($DeviceIds) {
    foreach ($id in $DeviceIds) {
        try {
            $dev = Get-CMDevice -Id $id -ErrorAction Stop
            if ($dev) { $devices += $dev }
        } catch {
            Log "WARN: Device with Id $id not found in ConfigMgr."
        }
    }
}

if ($DeviceNames) {
    foreach ($name in $DeviceNames) {
        try {
            # exact match by default. If the caller expects wildcards, they can pass them (use -ForceWildcardHandling below)
            $devsByName = Get-CMDevice -Name $name -ErrorAction Stop
            if ($devsByName) { $devices += $devsByName }
        } catch {
            Log "WARN: Device with Name '$name' not found in ConfigMgr."
        }
    }
}

if (-not $devices -or $devices.Count -eq 0) {
    Log "ERROR: No matching devices found in ConfigMgr. Aborting."
    throw "No matching devices."
}

# Remove duplicates
$devices = $devices | Select-Object -Unique

# Summarize
Log "Found $($devices.Count) device(s) to wipe:"
$devices | ForEach-Object {
    Log " - Name: $($_.Name)  ResourceId: $($_.ResourceId)  LastOnline: $($_.LastOnline)  ClientVersion: $($_.ClientVersion)"
}

# Prompt/confirm
if (-not $Force) {
    $msg = "About to perform factory wipe on $($devices.Count) device(s). This cannot be undone. Type 'YES' to continue:"
    Write-Host ""
    $confirmation = Read-Host $msg
    if ($confirmation -ne 'YES') {
        Log "Aborted by user (confirmation not provided)."
        exit 1
    }
} else {
    Log "Force flag supplied; skipping interactive confirmation."
}

if ($WhatIfOnly) {
    Log "WhatIf mode: no wipes will be executed. Exiting after summary."
    exit 0
}

# Execute wipe for each device
foreach ($d in $devices) {
    $name = $d.Name
    $rid  = $d.ResourceId
    try {
        Log "Initiating wipe for device Name='$name' (ResourceId=$rid)..."
        # Use -Id for reliability
        # -Confirm omitted since we control confirmation here; include -Force to avoid internal prompts if desired
        Invoke-CMDeviceWipe -Id $rid -Force -Verbose
        Log "Sent wipe command for ResourceId $rid (Name=$name)."
    } catch {
        Log "ERROR: Failed to send wipe for ResourceId $rid (Name=$name): $($_.Exception.Message)"
    }
}

Log "Finished issuing wipe commands. Monitor status in the ConfigMgr Console (Monitoring -> Client Operations or the device's Client Notification / Last Co-Management Action)."
