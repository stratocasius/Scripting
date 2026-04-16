# Intune Detection Script - Teams Default Audio Health / Call Join Correlation
# Exit 0 = Compliant
# Exit 1 = Non-compliant

$ErrorActionPreference = "SilentlyContinue"

$LogRoot = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogPath = Join-Path $LogRoot "TeamsAudioDefaultDetection-$Stamp.log"

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

function Test-TextContainsAny {
    param(
        [string]$Text,
        [string[]]$Needles
    )

    if ([string]::IsNullOrWhiteSpace($Text) -or -not $Needles) {
        return $false
    }

    foreach ($needle in $Needles) {
        if (-not [string]::IsNullOrWhiteSpace($needle) -and
            $Text.IndexOf($needle, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            return $true
        }
    }

    return $false
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
        if (Get-Command Get-PnpDevice -ErrorAction SilentlyContinue) {
            $devices += Get-PnpDevice -Class AudioEndpoint -ErrorAction SilentlyContinue
            $devices += Get-PnpDevice -Class Media -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Log "Get-AudioDevices failed: $($_.Exception.Message)"
    }

    return @($devices) | Where-Object { $_ -ne $null }
}

function Get-ActiveAudioEndpoints {
    $devices = Get-AudioDevices
    return @($devices | Where-Object { $_.Status -eq "OK" })
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
    param(
        [string]$Sid
    )

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
            Available      = $false
            MissingPlayback = $null
            MissingRecord   = $null
            PlaybackName    = $null
            RecordName      = $null
            Note            = "No interactive-user default mapping available"
        }
    }

    $playbackName = $mapping.Playback
    $recordName   = $mapping.Record

    $endpointNames = @(
        $ActiveEndpoints | ForEach-Object {
            $_.FriendlyName
            $_.Name
        } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
    )

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
        Available      = $true
        MissingPlayback = -not $playbackFound
        MissingRecord   = -not $recordFound
        PlaybackName    = $playbackName
        RecordName      = $recordName
        Note            = $null
    }
}

function Get-RecentAudioOperationalIssues {
    param(
        [int]$HoursBack = 72,
        [string]$PlaybackName,
        [string]$RecordName
    )

    $startTime = (Get-Date).AddHours(-$HoursBack)

    try {
        $events = Get-WinEvent -FilterHashtable @{
            LogName   = 'Microsoft-Windows-Audio/Operational'
            Level     = 2, 3
            StartTime = $startTime
        } -ErrorAction SilentlyContinue

        if (-not $events) {
            return @()
        }

        $needles = @(
            $PlaybackName,
            $RecordName,
            "audio",
            "endpoint",
            "device",
            "capture",
            "render",
            "initialize",
            "failed",
            "error"
        ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

        $matches = foreach ($evt in $events) {
            if (Test-TextContainsAny -Text $evt.Message -Needles $needles) {
                $evt
            }
        }

        return @($matches)
    }
    catch {
        Write-Log "Audio operational query failed: $($_.Exception.Message)"
        return @()
    }
}

function Get-RecentTeamsCrashSignals {
    param([int]$HoursBack = 72)

    $startTime = (Get-Date).AddHours(-$HoursBack)

    $results = [PSCustomObject]@{
        TeamsCrashes   = @()
        WebView2Crashes = @()
    }

    try {
        $appEvents = Get-WinEvent -FilterHashtable @{
            LogName   = 'Application'
            Id        = 1000, 1001, 1002
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
    }
    catch {
        Write-Log "Teams crash query failed: $($_.Exception.Message)"
    }

    return $results
}

try {
    Write-Log "=== Detection run started ==="
    Write-Log "Lookback window: 72 hours"

    $loggedOnSid = Get-LoggedOnUserSid
    if ($loggedOnSid) {
        Write-Log "Logged-on user SID: $loggedOnSid"
    }
    else {
        Write-Log "Logged-on user SID: None"
    }

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

    $audioIssues = Get-RecentAudioOperationalIssues -HoursBack 72 -PlaybackName $defaultCheck.PlaybackName -RecordName $defaultCheck.RecordName
    Write-Log ("Recent Windows Audio Operational issues: {0}" -f $audioIssues.Count)

    foreach ($evt in ($audioIssues | Select-Object -First 5)) {
        Write-Log ("Audio operational event: {0} | {1}" -f $evt.Id, ($evt.Message -replace '\s+', ' '))
    }

    $recent = Get-RecentTeamsCrashSignals -HoursBack 72
    Write-Log ("Recent Teams crash/hang events: {0}" -f $recent.TeamsCrashes.Count)
    Write-Log ("Recent WebView2 crash/hang events: {0}" -f $recent.WebView2Crashes.Count)

    foreach ($evt in ($recent.TeamsCrashes | Select-Object -First 5)) {
        Write-Log ("Teams/WebView2 event: {0} | {1}" -f $evt.Id, ($evt.Message -replace '\s+', ' '))
    }

    $nonCompliant = $false
    $reasons = @()

    if (-not $defaultCheck.Available) {
        $nonCompliant = $true
        $reasons += "NoDefaultMapping"
    }

    if ($defaultCheck.Available -and ($defaultCheck.MissingPlayback -or $defaultCheck.MissingRecord)) {
        $nonCompliant = $true
        $reasons += "DefaultDeviceMissing"
    }

    if ($activeEndpoints.Count -lt 1) {
        $nonCompliant = $true
        $reasons += "NoActiveAudioEndpoints"
    }

    if ($serviceIssues.Count -gt 0) {
        $nonCompliant = $true
        $reasons += "AudioServiceIssue"
    }

    if ($audioIssues.Count -gt 0) {
        $nonCompliant = $true
        $reasons += "RecentAudioOperationalIssue"
    }

    if ($recent.TeamsCrashes.Count -gt 0 -or $recent.WebView2Crashes.Count -gt 0) {
        $nonCompliant = $true
        $reasons += "TeamsOrWebView2CrashSignal"
    }

    $summary = "DefaultPlayback=$($defaultCheck.PlaybackName);DefaultRecord=$($defaultCheck.RecordName);ActiveEndpoints=$($activeEndpoints.Count);AudioOps=$($audioIssues.Count);TeamsCrashSignals=$($recent.TeamsCrashes.Count);WebView2Signals=$($recent.WebView2Crashes.Count);Reasons=$($reasons -join ',')"
    Write-Log "SUMMARY: $summary"
    Write-Output $summary

    if ($nonCompliant) {
        Write-Log "RESULT: Non-compliant"
        exit 1
    }

    Write-Log "RESULT: Compliant"
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Output "Detection failed"
    exit 1
}