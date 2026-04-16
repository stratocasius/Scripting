# Intune Remediation Script - Teams Audio / Windows Audio Recovery
# Exit 0 = Remediation completed
# Exit 1 = Remediation failed

$ErrorActionPreference = "SilentlyContinue"

$LogRoot = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogPath = Join-Path $LogRoot "TeamsAudioRemediation-$Stamp.log"

if (-not (Test-Path $LogRoot)) {
    New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "$time | $Message"
}

function Get-AudioDevices {
    $devices = @()

    try {
        if (Get-Command Get-PnpDevice -ErrorAction SilentlyContinue) {
            $devices += Get-PnpDevice -Class AudioEndpoint -ErrorAction SilentlyContinue
            $devices += Get-PnpDevice -Class Media -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Log "Get-AudioDevices failed: $($_.Exception.Message)"
    }

    @($devices) | Where-Object { $_ -ne $null }
}

function Restart-AudioServices {
    $services = @("AudioEndpointBuilder", "Audiosrv", "MMCSS")

    foreach ($svcName in $services) {
        try {
            $svc = Get-Service -Name $svcName -ErrorAction Stop
            Set-Service -Name $svcName -StartupType Automatic -ErrorAction SilentlyContinue

            if ($svc.Status -eq "Running") {
                Restart-Service -Name $svcName -Force -ErrorAction SilentlyContinue
                Write-Log "Restarted service: $svcName"
            }
            else {
                Start-Service -Name $svcName -ErrorAction SilentlyContinue
                Write-Log "Started service: $svcName"
            }
        }
        catch {
            Write-Log "Failed service action for $svcName: $($_.Exception.Message)"
        }
    }
}

function Enable-AudioDevices {
    try {
        if (-not (Get-Command Enable-PnpDevice -ErrorAction SilentlyContinue)) {
            Write-Log "Enable-PnpDevice cmdlet not available."
            return
        }

        $devices = Get-AudioDevices | Where-Object {
            $_.Status -eq "Disabled" -or $_.Status -eq "Error" -or $_.Problem -eq 22
        }

        foreach ($dev in $devices) {
            if ([string]::IsNullOrWhiteSpace($dev.InstanceId)) {
                Write-Log "Skipped device with empty InstanceId."
                continue
            }

            try {
                Enable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
                Write-Log "Enabled device: $($dev.FriendlyName) | InstanceId=$($dev.InstanceId)"
            }
            catch {
                Write-Log "Failed to enable device: $($dev.FriendlyName) | InstanceId=$($dev.InstanceId) | $($_.Exception.Message)"
            }
        }

        if (-not $devices -or $devices.Count -eq 0) {
            Write-Log "No disabled audio devices found to enable."
        }
    }
    catch {
        Write-Log "Device enable step failed: $($_.Exception.Message)"
    }
}

function Rescan-Devices {
    try {
        $pnputil = Join-Path $env:WINDIR "System32\pnputil.exe"
        if (Test-Path $pnputil) {
            $p = Start-Process -FilePath $pnputil -ArgumentList "/scan-devices" -Wait -PassThru -WindowStyle Hidden -ErrorAction SilentlyContinue
            if ($p) {
                Write-Log "pnputil /scan-devices exit code: $($p.ExitCode)"
            }
            else {
                Write-Log "pnputil /scan-devices started but no exit code was returned."
            }
        }
        else {
            Write-Log "pnputil.exe not found."
        }
    }
    catch {
        Write-Log "pnputil scan failed: $($_.Exception.Message)"
    }
}

function Get-ActiveAudioEndpointCount {
    try {
        $devices = Get-AudioDevices | Where-Object {
            $_.Status -eq "OK"
        }

        return @($devices).Count
    }
    catch {
        return 0
    }
}

try {
    Write-Log "=== Remediation run started ==="

    Restart-AudioServices
    Start-Sleep -Seconds 5

    Rescan-Devices
    Start-Sleep -Seconds 5

    Enable-AudioDevices
    Start-Sleep -Seconds 5

    Restart-AudioServices
    Start-Sleep -Seconds 5

    $endpointCount = Get-ActiveAudioEndpointCount
    Write-Log "Post-remediation active audio endpoint count: $endpointCount"

    if ($endpointCount -ge 1) {
        Write-Log "RESULT: Success"
        Write-Output "Audio remediation successful"
        exit 0
    }
    else {
        Write-Log "RESULT: Failed - No active audio endpoints restored"
        Write-Output "Audio remediation failed"
        exit 1
    }
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Output "Remediation failed"
    exit 1
}