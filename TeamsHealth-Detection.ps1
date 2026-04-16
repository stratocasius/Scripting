# Intune Proactive Remediation - Teams Health Detection
# Exit 0 = Compliant
# Exit 1 = Non-compliant

$ErrorActionPreference = "SilentlyContinue"

$LogRoot = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogPath = Join-Path $LogRoot "TeamsHealth-$Stamp.log"
$JsonPath = Join-Path $LogRoot "TeamsHealth-$Stamp.json"
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

function Get-CurrentUserName {
    try {
        $cs = Get-CimInstance Win32_ComputerSystem
        if (-not [string]::IsNullOrWhiteSpace($cs.UserName)) {
            return $cs.UserName.Split('\')[-1]
        }
    }
    catch { }
    return $env:USERNAME
}

function Get-TeamsVersion {
    try {
        $pkg = Get-AppxPackage -AllUsers -Name MSTeams -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($pkg) {
            return [PSCustomObject]@{
                Installed = $true
                Version   = $pkg.Version.ToString()
                Path      = $pkg.InstallLocation
            }
        }
    }
    catch { }

    return [PSCustomObject]@{
        Installed = $false
        Version   = $null
        Path      = $null
    }
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
                Path      = $items.InstallLocation
            }
        }
    }
    catch { }

    $candidateFiles = @(
        "$env:ProgramFiles (x86)\Microsoft\EdgeWebView\Application\msedgewebview2.exe",
        "$env:ProgramFiles\Microsoft\EdgeWebView\Application\msedgewebview2.exe"
    )

    foreach ($file in $candidateFiles) {
        if (Test-Path $file) {
            try {
                $ver = (Get-Item $file).VersionInfo.ProductVersion
                return [PSCustomObject]@{
                    Installed = $true
                    Version   = $ver
                    Path      = $file
                }
            }
            catch { }
        }
    }

    return [PSCustomObject]@{
        Installed = $false
        Version   = $null
        Path      = $null
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
    catch { }
    return @($devices) | Where-Object { $_ -ne $null }
}

function Get-ActiveAudioEndpoints {
    return @(Get-AudioDevices | Where-Object { $_.Status -eq "OK" })
}

function Get-AudioServices {
    $services = @("Audiosrv", "AudioEndpointBuilder", "MMCSS")
    $result = @()

    foreach ($svcName in $services) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        $status = if ($svc) { $svc.Status.ToString() } else { "Missing" }
        $result += [PSCustomObject]@{
            Name   = $svcName
            Status = $status
        }
    }

    return $result
}

function Get-DefaultAudioMapping {
    param([string]$Sid)

    if ([string]::IsNullOrWhiteSpace($Sid)) { return $null }

    try {
        $path = "Registry::HKEY_USERS\$Sid\Software\Microsoft\Multimedia\Sound Mapper"
        if (-not (Test-Path $path)) { return $null }

        $props = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
        if (-not $props) { return $null }

        return [PSCustomObject]@{
            Playback = [string]$props.Playback
            Record   = [string]$props.Record
        }
    }
    catch { return $null }
}

function Test-DefaultDevicePresent {
    param(
        [string]$Sid,
        [array]$ActiveEndpoints
    )

    $mapping = Get-DefaultAudioMapping -Sid $Sid
    if (-not $mapping) {
        return [PSCustomObject]@{
            Available       = $false
            MissingPlayback  = $null
            MissingRecord    = $null
            PlaybackName     = $null
            RecordName       = $null
        }
    }

    $endpointNames = @(
        $ActiveEndpoints | ForEach-Object {
            $_.FriendlyName
            $_.Name
        } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
    )

    $playbackFound = $false
    $recordFound   = $false

    foreach ($n in $endpointNames) {
        if (-not $playbackFound -and $mapping.Playback -and ($n -like "*$($mapping.Playback)*" -or $mapping.Playback -like "*$n*")) {
            $playbackFound = $true
        }
        if (-not $recordFound -and $mapping.Record -and ($n -like "*$($mapping.Record)*" -or $mapping.Record -like "*$n*")) {
            $recordFound = $true
        }
    }

    return [PSCustomObject]@{
        Available       = $true
        MissingPlayback  = -not $playbackFound
        MissingRecord    = -not $recordFound
        PlaybackName     = $mapping.Playback
        RecordName       = $mapping.Record
    }
}

function Get-RecentSignals {
    param([int]$HoursBack)

    $start = (Get-Date).AddHours(-$HoursBack)

    $appEvents = @()
    $sysEvents = @()
    $audioOpEvents = @()

    try {
        $appEvents = Get-WinEvent -FilterHashtable @{
            LogName   = 'Application'
            StartTime = $start
        } -ErrorAction SilentlyContinue | Where-Object {
            $_.Message -match 'Teams|MSTeams|ms-teams\.exe|msedgewebview2|WebView2'
        }
    }
    catch { }

    try {
        $sysEvents = Get-WinEvent -FilterHashtable @{
            LogName   = 'System'
            StartTime = $start
            Id        = 219,7031,7034
        } -ErrorAction SilentlyContinue | Where-Object {
            $_.Message -match 'Audiosrv|AudioEndpointBuilder|Windows Audio|MMCSS|audio|hdaudio|realtek|intel|bluetooth'
        }
    }
    catch { }

    try {
        $audioOpEvents = Get-WinEvent -FilterHashtable @{
            LogName   = 'Microsoft-Windows-Audio/Operational'
            StartTime = $start
        } -ErrorAction SilentlyContinue | Where-Object {
            $_.LevelDisplayName -in @('Error','Warning')
        }
    }
    catch { }

    return [PSCustomObject]@{
        AppEvents      = @($appEvents)
        SystemEvents   = @($sysEvents)
        AudioOpEvents  = @($audioOpEvents)
    }
}

function Get-Grade {
    param([int]$Score)
    switch ($Score) {
        { $_ -ge 90 } { "A"; break }
        { $_ -ge 80 } { "B"; break }
        { $_ -ge 70 } { "C"; break }
        { $_ -ge 60 } { "D"; break }
        default       { "F" }
    }
}

try {
    $user = Get-CurrentUserName
    $sid  = Get-CurrentUserSid

    Write-Log "=== Teams Health Detection Started ==="
    Write-Log "User: $user"
    Write-Log "SID: $sid"
    Write-Log "Lookback Hours: $HoursBack"

    $teams = Get-TeamsVersion
    $webv2 = Get-WebView2Version
    $audioServices = Get-AudioServices
    $activeEndpoints = Get-ActiveAudioEndpoints
    $defaultCheck = Test-DefaultDevicePresent -Sid $sid -ActiveEndpoints $activeEndpoints
    $signals = Get-RecentSignals -HoursBack $HoursBack

    $issues = @()
    $score = 100

    if (-not $teams.Installed) {
        $issues += "TeamsMissing"
        $score -= 40
    }

    if (-not $webv2.Installed) {
        $issues += "WebView2Missing"
        $score -= 20
    }

    $badServices = @($audioServices | Where-Object { $_.Status -ne "Running" })
    if ($badServices.Count -gt 0) {
        $issues += "AudioServiceIssue"
        $score -= 25
    }

    if ($activeEndpoints.Count -lt 1) {
        $issues += "NoAudioEndpoints"
        $score -= 30
    }

    if ($defaultCheck.Available) {
        if ($defaultCheck.MissingPlayback -or $defaultCheck.MissingRecord) {
            $issues += "DefaultAudioMissing"
            $score -= 15
        }
    }
    else {
        $issues += "NoDefaultMapping"
        $score -= 10
    }

    if ($signals.AppEvents.Count -gt 0) {
        $issues += "TeamsOrWebView2Crashes"
        $score -= [Math]::Min(30, ($signals.AppEvents.Count * 5))
    }

    if ($signals.SystemEvents.Count -gt 0) {
        $issues += "AudioDriverOrServiceEvents"
        $score -= [Math]::Min(30, ($signals.SystemEvents.Count * 5))
    }

    if ($signals.AudioOpEvents.Count -gt 0) {
        $issues += "AudioOperationalIssues"
        $score -= [Math]::Min(20, ($signals.AudioOpEvents.Count * 3))
    }

    if ($score -lt 0) { $score = 0 }

    $status = if ($score -ge $ComplianceThreshold -and $issues.Count -eq 0) { "Compliant" } else { "Non-Compliant" }

    $dashboard = [PSCustomObject]@{
        ComputerName    = $env:COMPUTERNAME
        UserName        = $user
        TeamsVersion    = if ($teams.Installed) { $teams.Version } else { "NotInstalled" }
        WebView2Version = if ($webv2.Installed) { $webv2.Version } else { "NotInstalled" }
        AudioStatus     = if ($badServices.Count -eq 0 -and $activeEndpoints.Count -ge 1) { "Healthy" } else { "Issue" }
        DefaultPlayback = if ($defaultCheck.PlaybackName) { $defaultCheck.PlaybackName } else { "None" }
        DefaultRecord   = if ($defaultCheck.RecordName) { $defaultCheck.RecordName } else { "None" }
        ActiveEndpoints = $activeEndpoints.Count
        AppCrashes      = $signals.AppEvents.Count
        SystemEvents    = $signals.SystemEvents.Count
        AudioOpEvents   = $signals.AudioOpEvents.Count
        Score           = $score
        Grade           = (Get-Grade -Score $score)
        Status          = $status
        Issues          = ($issues | Select-Object -Unique) -join ","
        TimeStamp       = (Get-Date).ToString("s")
    }

    $summary = "TeamsHealthScore=$($dashboard.Score) | Status=$($dashboard.Status) | TeamsVersion=$($dashboard.TeamsVersion) | WebView2=$($dashboard.WebView2Version) | Audio=$($dashboard.AudioStatus) | Default=$($dashboard.DefaultPlayback)/$($dashboard.DefaultRecord) | Crashes=$($dashboard.AppCrashes) | AudioEvents=$($dashboard.SystemEvents) | Grade=$($dashboard.Grade) | Issues=$($dashboard.Issues)"

    Write-Log "SUMMARY: $summary"
    $dashboard | ConvertTo-Json -Depth 5 | Out-File -FilePath $JsonPath -Encoding utf8 -Force
    Write-Output $summary

    if ($dashboard.Status -eq "Compliant") { exit 0 }
    exit 1
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Output "TeamsHealthScore=0 | Status=Non-Compliant | TeamsVersion=Unknown | WebView2=Unknown | Audio=Issue | Default=None/None | Crashes=0 | AudioEvents=0 | Grade=F | Issues=DetectionFailed"
    exit 1
}