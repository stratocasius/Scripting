# Intune Detection Script - Teams Audio / Windows Audio Health
# Exit 0 = Compliant
# Exit 1 = Non-compliant

$ErrorActionPreference = "SilentlyContinue"

$LogRoot = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogPath = Join-Path $LogRoot "TeamsAudioDetection-$Stamp.log"

if (-not (Test-Path $LogRoot)) {
    New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param([string]$Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "$time | $Message"
}

function Get-LoggedOnUserSid {
    try {
        $cs = Get-CimInstance Win32_ComputerSystem
        if ([string]::IsNullOrWhiteSpace($cs.UserName)) {
            return $null
        }

        $nt = New-Object System.Security.Principal.NTAccount($cs.UserName)
        return $nt.Translate([System.Security.Principal.SecurityIdentifier]).Value
    }
    catch {
        return $null
    }
}

function Get-AudioDevices {
    $devices = @()

    try {
        Import-Module PnpDevice -ErrorAction SilentlyContinue | Out-Null

        $devices += Get-PnpDevice -Class AudioEndpoint -ErrorAction SilentlyContinue
        $devices += Get-PnpDevice -Class Media -ErrorAction SilentlyContinue
    }
    catch { }

    return @($devices)
}

function Get-ActiveAudioEndpoints {
    $devices = Get-AudioDevices
    return @($devices | Where-Object { $_.Status -eq 'OK' })
}

function Get-AudioServiceIssues {
    $services = @("Audiosrv", "AudioEndpointBuilder", "MMCSS")
    $issues = @()

    foreach ($svcName in $services) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if (-not $svc) {
            $issues += "$svcName:Missing"
            continue
        }

        if ($svc.Status -ne "Running") {
            $issues += "$svcName $($svc.Status)"
        }
    }

    return @($issues)
}

function Get-DefaultAudioMapping {
    param([string]$Sid)

    if ([string]::IsNullOrWhiteSpace($Sid)) {
        return $null
    }

    try {
        $path = "Registry::HKEY_USERS\$Sid\Software\Microsoft\Multimedia\Sound Mapper"
        if (-not (Test-Path $path)) {
            return $null
        }

        $props = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
        if (-not $props) {
            return $null
        }

        [PSCustomObject]@{
            Playback = [string]$props.Playback
            Record   = [string]$props.Record
        }
    }
    catch {
        return $null
    }
}

function Test-DefaultDevicePresent {
    param(
        [string]$Sid,
        [array]$ActiveEndpoints
    )

    $mapping = Get-DefaultAudioMapping -Sid $Sid
    if (-not $mapping) {
        return [PSCustomObject]@{
            Available = $false
            MissingPlayback = $null
            MissingRecord = $null
            PlaybackName = $null
            RecordName = $null
            Note = "No interactive-user default mapping available"
        }
    }

    $playbackName = $mapping.Playback
    $recordName   = $mapping.Record

    $endpointNames = @($ActiveEndpoints | ForEach-Object {
        $_.FriendlyName
        $_.Name
    } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)

    $playbackFound = $false
    $recordFound = $false

    foreach ($n in $endpointNames) {
        if (-not $playbackFound -and $playbackName -and ($n -like "*$playbackName*" -or $playbackName -like "*$n*")) {
            $playbackFound = $true
        }
        if (-not $recordFound -and $recordName -and ($n -like "*$recordName*" -or $recordName -like "*$n*")) {
            $recordFound = $true
        }
    }

    [PSCustomObject]@{
        Available = $true
        MissingPlayback = -not $playbackFound
        MissingRecord = -not $recordFound
        PlaybackName = $playbackName
        RecordName = $recordName
        Note = $null
    }
}

function Get-RecentAudioTeamsEvents {
    param([int]$HoursBack = 72)

    $startTime = (Get-Date).AddHours(-$HoursBack)

    $results = [PSCustomObject]@{
        TeamsCrashes = @()
        WebView2Crashes = @()
        AudioServiceFailures = @()
    }

    try {
        $appEvents = Get-WinEvent -FilterHashtable @{
            LogName   = 'Application'
            Id        = 1000,1001,1002
            StartTime = $startTime
        } -ErrorAction SilentlyContinue

        if ($appEvents) {
            $results.TeamsCrashes = @(
                $appEvents | Where-Object {
                    $_.Message -match 'Teams|MSTeams|ms-teams\.exe|msedgewebview2\.exe|WebView2'
                }
            )
            $results.WebView2Crashes = @(
                $appEvents | Where-Object {
                    $_.Message -match 'msedgewebview2\.exe|WebView2'
                }
            )
        }

        $sysEvents = Get-WinEvent -FilterHashtable @{
            LogName   = 'System'
            Id        = 7031,7034
            StartTime = $startTime
        } -ErrorAction SilentlyContinue

        if ($sysEvents) {
            $results.AudioServiceFailures = @(
                $sysEvents | Where-Object {
                    $_.Message -match 'Audiosrv|AudioEndpointBuilder|Windows Audio|Audio Endpoint Builder|MMCSS'
                }
            )
        }
    }
    catch { }

    return $results
}

try {
    Write-Log "=== Detection run started ==="
    Write-Log "Lookback window: 72 hours"

    $loggedOnSid = Get-LoggedOnUserSid
    Write-Log ("Logged-on user SID: {0}" -f ($loggedOnSid ?? "None"))

    $activeEndpoints = Get-ActiveAudioEndpoints
    Write-Log "Active audio endpoints found: $($activeEndpoints.Count)"
    foreach ($ep in $activeEndpoints) {
        Write-Log ("Endpoint OK: {0} | Class={1} | InstanceId={2}" -f $ep.FriendlyName, $ep.Class, $ep.InstanceId)
    }

    $serviceIssues = Get-AudioServiceIssues
    if ($serviceIssues.Count -gt 0) {
        Write-Log ("Audio service issues: {0}" -f ($serviceIssues -join "; "))
    }
    else {
        Write-Log "Audio services: Healthy"
    }

    $defaultCheck = Test-DefaultDevicePresent -Sid $loggedOnSid -ActiveEndpoints $activeEndpoints
    if ($defaultCheck.Available) {
        Write-Log ("Default playback device mapping: {0}" -f $defaultCheck.PlaybackName)
        Write-Log ("Default record device mapping: {0}" -f $defaultCheck.RecordName)
        Write-Log ("Default playback missing: {0}" -f $defaultCheck.MissingPlayback)
        Write-Log ("Default record missing: {0}" -f $defaultCheck.MissingRecord)
    }
    else {
        Write-Log ("Default device mapping unavailable: {0}" -f $defaultCheck.Note)
    }

    $recent = Get-RecentAudioTeamsEvents -HoursBack 72
    Write-Log ("Recent Teams crash/hang events: {0}" -f $recent.TeamsCrashes.Count)
    Write-Log ("Recent WebView2 crash/hang events: {0}" -f $recent.WebView2Crashes.Count)
    Write-Log ("Recent audio service failure events: {0}" -f $recent.AudioServiceFailures.Count)

    foreach ($evt in ($recent.TeamsCrashes | Select-Object -First 5)) {
        Write-Log ("Teams/WebView2 event: {0} | {1}" -f $evt.Id, ($evt.Message -replace '\s+', ' '))
    }

    foreach ($evt in ($recent.AudioServiceFailures | Select-Object -First 5)) {
        Write-Log ("Audio service event: {0} | {1}" -f $evt.Id, ($evt.Message -replace '\s+', ' '))
    }

    if ($activeEndpoints.Count -lt 1) {
        Write-Log "RESULT: Non-compliant - No active audio endpoints"
        Write-Output "No active audio endpoints detected"
        exit 1
    }

    if ($serviceIssues.Count -gt 0) {
        Write-Log "RESULT: Non-compliant - Audio services not healthy"
        Write-Output "Audio services not running"
        exit 1
    }

    if ($defaultCheck.Available -and ($defaultCheck.MissingPlayback -or $defaultCheck.MissingRecord)) {
        Write-Log "RESULT: Non-compliant - Default audio mapping missing"
        Write-Output "Default audio device mapping missing"
        exit 1
    }

    if ($recent.TeamsCrashes.Count -gt 0 -or $recent.WebView2Crashes.Count -gt 0 -or $recent.AudioServiceFailures.Count -gt 0) {
        Write-Log "RESULT: Non-compliant - Recent Teams/WebView2/audio failure events detected"
        Write-Output "Recent Teams/WebView2/audio failure events detected"
        exit 1
    }

    Write-Log "RESULT: Compliant"
    Write-Output "Audio system healthy"
    exit 0
}
catch {
    Write-Log ("ERROR: {0}" -f $_.Exception.Message)
    Write-Output "Detection failed"
    exit 1
}