# Intune Proactive Remediation - Teams Health Remediation
# Exit 0 = Remediation completed successfully
# Exit 1 = Remediation failed or partially failed

$ErrorActionPreference = "SilentlyContinue"

$LogRoot = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogPath = Join-Path $LogRoot "TeamsHealthRemediation-$Stamp.log"
$JsonPath = Join-Path $LogRoot "TeamsHealthRemediation-$Stamp.json"
$HoursBack = 72
$ComplianceThreshold = 70

if (-not (Test-Path $LogRoot)) {
    New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param([string]$Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "$time | $Message"
}

function Get-CurrentUserSid {
    try {
        $cs = Get-CimInstance Win32_ComputerSystem
        if ([string]::IsNullOrWhiteSpace($cs.UserName)) { return $null }
        $nt = New-Object System.Security.Principal.NTAccount($cs.UserName)
        return $nt.Translate([System.Security.Principal.SecurityIdentifier]).Value
    }
    catch { return $null }
}

function Get-CurrentUserProfilePath {
    param([string]$Sid)
    try {
        if ([string]::IsNullOrWhiteSpace($Sid)) { return $null }
        $profile = Get-CimInstance Win32_UserProfile -ErrorAction SilentlyContinue |
            Where-Object { $_.SID -eq $Sid } | Select-Object -First 1
        if ($profile -and $profile.LocalPath) { return $profile.LocalPath }
    }
    catch { }
    return $null
}

function Stop-TeamsProcesses {
    $names = @("ms-teams", "MSTeams", "msedgewebview2", "WebViewHost", "Microsoft Teams")
    foreach ($n in $names) {
        try {
            Get-Process -Name $n -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            Write-Log "Stopped process: $n"
        }
        catch {
            Write-Log "Could not stop process: $n"
        }
    }
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
            Write-Log "Failed audio service action for $svcName: $($_.Exception.Message)"
        }
    }
}

function Enable-AudioDevices {
    try {
        if (-not (Get-Command Get-PnpDevice -ErrorAction SilentlyContinue)) {
            Write-Log "Get-PnpDevice not available."
            return
        }

        $devices = @(
            Get-PnpDevice -Class AudioEndpoint -ErrorAction SilentlyContinue
            Get-PnpDevice -Class Media -ErrorAction SilentlyContinue
        ) | Where-Object {
            $_.Status -eq "Disabled" -or $_.Status -eq "Error" -or $_.Problem -eq 22
        }

        foreach ($dev in $devices) {
            if ([string]::IsNullOrWhiteSpace($dev.InstanceId)) { continue }
            try {
                Enable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
                Write-Log "Enabled device: $($dev.FriendlyName) | $($dev.InstanceId)"
            }
            catch {
                Write-Log "Failed to enable device: $($dev.FriendlyName) | $($_.Exception.Message)"
            }
        }
    }
    catch {
        Write-Log "Enable-AudioDevices failed: $($_.Exception.Message)"
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
        }
    }
    catch {
        Write-Log "Rescan-Devices failed: $($_.Exception.Message)"
    }
}

function Clear-TeamsCache {
    param([string]$ProfilePath)

    if ([string]::IsNullOrWhiteSpace($ProfilePath)) { return }

    $possibleRoots = @(
        (Join-Path $ProfilePath "AppData\Local\Packages"),
        (Join-Path $ProfilePath "AppData\Roaming\Microsoft\Teams")
    )

    foreach ($root in $possibleRoots) {
        if (-not (Test-Path $root)) { continue }

        try {
            Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue | Where-Object {
                $_.Name -like "MSTeams*"
            } | ForEach-Object {
                $paths = @(
                    (Join-Path $_.FullName "LocalCache"),
                    (Join-Path $_.FullName "TempState")
                )

                foreach ($p in $paths) {
                    if (Test-Path $p) {
                        try {
                            Remove-Item -Path (Join-Path $p "*") -Recurse -Force -ErrorAction SilentlyContinue
                            Write-Log "Cleared Teams cache path: $p"
                        }
                        catch {
                            Write-Log "Failed clearing cache path: $p"
                        }
                    }
                }
            }
        }
        catch {
            Write-Log "Teams cache sweep failed under $root: $($_.Exception.Message)"
        }
    }
}

function Get-TeamsVersion {
    try {
        $pkg = Get-AppxPackage -AllUsers -Name MSTeams -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($pkg) {
            return [PSCustomObject]@{
                Installed = $true
                Version   = $pkg.Version.ToString()
            }
        }
    }
    catch { }

    return [PSCustomObject]@{ Installed = $false; Version = $null }
}

function Get-WebView2Version {
    $keys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    try {
        $items = Get-ItemProperty -Path $keys -ErrorAction SilentlyContinue | Where-Object {
            $_.DisplayName -like "*Microsoft Edge WebView2 Runtime*"
        } | Select-Object -First 1

        if ($items -and $items.DisplayVersion) {
            return [PSCustomObject]@{
                Installed = $true
                Version   = $items.DisplayVersion
            }
        }
    }
    catch { }

    return [PSCustomObject]@{ Installed = $false; Version = $null }
}

function Get-AudioHealthQuick {
    $servicesOk = $true
    foreach ($svcName in @("Audiosrv", "AudioEndpointBuilder", "MMCSS")) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if (-not $svc -or $svc.Status -ne "Running") {
            $servicesOk = $false
        }
    }

    $endpointCount = 0
    try {
        if (Get-Command Get-PnpDevice -ErrorAction SilentlyContinue) {
            $endpointCount = @(
                Get-PnpDevice -Class AudioEndpoint -ErrorAction SilentlyContinue |
                    Where-Object { $_.Status -eq "OK" }
            ).Count
        }
    }
    catch { }

    return [PSCustomObject]@{
        ServicesOk    = $servicesOk
        EndpointCount = $endpointCount
    }
}

function Get-Assessment {
    $teams = Get-TeamsVersion
    $webv2 = Get-WebView2Version
    $audio  = Get-AudioHealthQuick

    $score = 100
    $issues = @()

    if (-not $teams.Installed) { $score -= 40; $issues += "TeamsMissing" }
    if (-not $webv2.Installed) { $score -= 20; $issues += "WebView2Missing" }
    if (-not $audio.ServicesOk) { $score -= 25; $issues += "AudioServiceIssue" }
    if ($audio.EndpointCount -lt 1) { $score -= 25; $issues += "NoAudioEndpoints" }

    if ($score -lt 0) { $score = 0 }

    return [PSCustomObject]@{
        TeamsInstalled   = $teams.Installed
        TeamsVersion     = $teams.Version
        WebView2Installed= $webv2.Installed
        WebView2Version  = $webv2.Version
        AudioServicesOk  = $audio.ServicesOk
        AudioEndpoints   = $audio.EndpointCount
        Score            = $score
        Grade            = if ($score -ge 90) { "A" } elseif ($score -ge 80) { "B" } elseif ($score -ge 70) { "C" } elseif ($score -ge 60) { "D" } else { "F" }
        Issues           = ($issues -join ",")
        TimeStamp        = (Get-Date).ToString("s")
    }
}

try {
    Write-Log "=== Teams Health Remediation Started ==="

    $sid = Get-CurrentUserSid
    $profile = Get-CurrentUserProfilePath -Sid $sid
    Write-Log "SID: $sid"
    Write-Log "Profile: $profile"

    $before = Get-Assessment
    $before | ConvertTo-Json -Depth 4 | Out-File -FilePath $JsonPath -Encoding utf8 -Force

    Write-Log ("Pre-remediation score: {0} | Issues: {1}" -f $before.Score, $before.Issues)

    if (-not $before.TeamsInstalled) {
        Write-Log "Teams is not installed. Remediation stops here."
        Write-Output "TeamsHealthScore=0 | Status=Non-Compliant | TeamsVersion=NotInstalled | WebView2=$($before.WebView2Version) | Audio=Issue | Grade=F | Issues=TeamsMissing"
        exit 1
    }

    Stop-TeamsProcesses
    Restart-AudioServices
    Rescan-Devices
    Enable-AudioDevices
    Clear-TeamsCache -ProfilePath $profile

    Start-Sleep -Seconds 10

    $after = Get-Assessment
    $after | ConvertTo-Json -Depth 4 | Out-File -FilePath $JsonPath -Encoding utf8 -Force

    $status = if ($after.Score -ge $ComplianceThreshold) { "Compliant" } else { "Non-Compliant" }
    $summary = "TeamsHealthScore=$($after.Score) | Status=$status | TeamsVersion=$($after.TeamsVersion) | WebView2=$($after.WebView2Version) | Audio=$(if ($after.AudioServicesOk -and $after.AudioEndpoints -ge 1) { 'Healthy' } else { 'Issue' }) | Endpoints=$($after.AudioEndpoints) | Grade=$($after.Grade) | Issues=$($after.Issues)"

    Write-Log "SUMMARY: $summary"
    Write-Output $summary

    if ($after.Score -ge $ComplianceThreshold -and $after.Issues -eq "") {
        exit 0
    }

    exit 1
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Output "TeamsHealthScore=0 | Status=Non-Compliant | TeamsVersion=Unknown | WebView2=Unknown | Audio=Issue | Grade=F | Issues=RemediationFailed"
    exit 1
}