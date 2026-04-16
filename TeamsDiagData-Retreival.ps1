$ErrorActionPreference = "SilentlyContinue"

$hoursBack = 72
$startTime = (Get-Date).AddHours(-$hoursBack)

$exportFolder = "C:\jltools"
$computerName = $env:COMPUTERNAME
$exportPath = Join-Path $exportFolder "$computerName-TeamsDiagData.csv"

if (-not (Test-Path $exportFolder)) {
    New-Item -Path $exportFolder -ItemType Directory -Force | Out-Null
}

function Get-CurrentUserName {
    try {
        $cs = Get-CimInstance Win32_ComputerSystem
        if (-not [string]::IsNullOrWhiteSpace($cs.UserName)) {
            return $cs.UserName
        }
    }
    catch { }

    try {
        $who = whoami.exe 2>$null
        if (-not [string]::IsNullOrWhiteSpace($who)) {
            return $who
        }
    }
    catch { }

    return $env:USERNAME
}

function Get-DeviceContext {
    try {
        $cs = Get-CimInstance Win32_ComputerSystem
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

        [PSCustomObject]@{
            ComputerName   = $env:COMPUTERNAME
            UserName       = Get-CurrentUserName
            Domain         = $cs.Domain
            Manufacturer   = $cs.Manufacturer
            Model          = $cs.Model
            OSVersion      = $os.Caption
            OSBuild        = $os.BuildNumber
            Architecture   = $os.OSArchitecture
            CPUName        = $cpu.Name
        }
    }
    catch {
        [PSCustomObject]@{
            ComputerName   = $env:COMPUTERNAME
            UserName       = Get-CurrentUserName
            Domain         = $null
            Manufacturer   = $null
            Model          = $null
            OSVersion      = $null
            OSBuild        = $null
            Architecture   = $null
            CPUName        = $null
        }
    }
}

function Get-CorrelationCategory {
    param(
        [string]$LogType,
        [int]$Id,
        [string]$ProviderName,
        [string]$Message
    )

    $msg = ($Message | Out-String).ToLowerInvariant()
    $prov = ($ProviderName | Out-String).ToLowerInvariant()

    if ($LogType -eq "Application") {
        if ($msg -match 'msedgewebview2|webview2') {
            return "WebView2CrashOrHang"
        }
        if ($msg -match 'teams|msteams|ms-teams\.exe') {
            return "TeamsCrashOrHang"
        }
        if ($Id -eq 1000) {
            return "ApplicationCrash"
        }
        if ($Id -eq 1001) {
            return "WindowsErrorReporting"
        }
        if ($Id -eq 1002) {
            return "ApplicationHang"
        }
        return "ApplicationEvent"
    }

    if ($LogType -eq "System") {
        if ($Id -eq 219 -and ($msg -match 'audio|hdaudio|realtek|intel|bluetooth|device')) {
            return "AudioDriverLoadFailure"
        }
        if (($Id -eq 7031 -or $Id -eq 7034) -and ($msg -match 'audiosrv|audioendpointbuilder|windows audio|mmcss')) {
            return "AudioServiceFailure"
        }
        if ($prov -match 'kernel-pnp' -or $msg -match 'kernel-pnp') {
            return "PnPDeviceFailure"
        }
        return "SystemEvent"
    }

    return "Other"
}

function Get-EventRow {
    param(
        [string]$LogType,
        $Event,
        $DeviceContext
    )

    [PSCustomObject]@{
        ComputerName   = $DeviceContext.ComputerName
        UserName       = $DeviceContext.UserName
        Domain         = $DeviceContext.Domain
        Manufacturer   = $DeviceContext.Manufacturer
        Model          = $DeviceContext.Model
        OSVersion      = $DeviceContext.OSVersion
        OSBuild        = $DeviceContext.OSBuild
        Architecture   = $DeviceContext.Architecture
        CPUName        = $DeviceContext.CPUName
        LogType        = $LogType
        Correlation    = Get-CorrelationCategory -LogType $LogType -Id $Event.Id -ProviderName $Event.ProviderName -Message $Event.Message
        TimeCreated    = $Event.TimeCreated
        Id             = $Event.Id
        Level          = $Event.LevelDisplayName
        ProviderName   = $Event.ProviderName
        Message        = ($Event.Message -replace "`r|`n", " ")
    }
}

$deviceContext = Get-DeviceContext
$results = @()

try {
    # Application log: Teams / WebView2 events in the last 72 hours
    $appEvents = Get-WinEvent -FilterHashtable @{
        LogName   = 'Application'
        StartTime = $startTime
    } -ErrorAction SilentlyContinue | Where-Object {
        $_.Message -match 'Teams|msedgewebview2|WebView2|MSTeams|ms-teams\.exe'
    }

    foreach ($evt in $appEvents) {
        $results += Get-EventRow -LogType "Application" -Event $evt -DeviceContext $deviceContext
    }

    # System log: audio/service/driver failures in the last 72 hours
    $sysEvents = Get-WinEvent -FilterHashtable @{
        LogName   = 'System'
        StartTime = $startTime
        Id        = 219,7031,7034
    } -ErrorAction SilentlyContinue

    foreach ($evt in $sysEvents) {
        $results += Get-EventRow -LogType "System" -Event $evt -DeviceContext $deviceContext
    }

    if ($results.Count -gt 0) {
        $results |
            Sort-Object TimeCreated -Descending |
            Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8

        Write-Output "Exported $($results.Count) events to $exportPath"
    }
    else {
        Write-Output "No matching events found in the last 72 hours."
    }
}
catch {
    Write-Output "Export failed: $($_.Exception.Message)"
    exit 1
}