### UI Performance with rolling history / trend check - 03/18/2026
# Exit 0 = Compliant
# Exit 1 = Non-compliant(scores below 70)

$ErrorActionPreference = "SilentlyContinue"

$ComplianceThreshold = 70
$TrendDeltaThreshold = 10
$logRoot = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$historyFile = Join-Path $logRoot "UIPerf-History.json"

function Get-PercentScore {
    param(
        [double]$Value,
        [double]$GoodThreshold,
        [double]$BadThreshold,
        [bool]$LowerIsBetter = $true
    )

    if ($LowerIsBetter) {
        if ($Value -le $GoodThreshold) { return 100 }
        if ($Value -ge $BadThreshold) { return 0 }
        return [math]::Round((($BadThreshold - $Value) / ($BadThreshold - $GoodThreshold)) * 100, 0)
    } else {
        if ($Value -ge $GoodThreshold) { return 100 }
        if ($Value -le $BadThreshold) { return 0 }
        return [math]::Round((($Value - $BadThreshold) / ($GoodThreshold - $BadThreshold)) * 100, 0)
    }
}

function Get-Grade {
    param([int]$Score)
    switch ($Score) {
        { $_ -ge 90 } { "A"; break }
        { $_ -ge 80 } { "B"; break }
        { $_ -ge 70 } { "C"; break }
        { $_ -ge 60 } { "D"; break }
        default { "F" }
    }
}

function Get-UiPerfAssessment {
    $cpuSample = Get-Counter '\Processor(_Total)\% Processor Time'
    $cpuUsage = [math]::Round($cpuSample.CounterSamples[0].CookedValue, 1)

    $os = Get-CimInstance Win32_OperatingSystem
    $totalMemGB = [math]::Round(($os.TotalVisibleMemorySize / 1MB), 2)
    $freeMemGB  = [math]::Round(($os.FreePhysicalMemory / 1MB), 2)
    $usedMemPct = [math]::Round((($totalMemGB - $freeMemGB) / $totalMemGB) * 100, 1)

    $systemDriveLetter = $env:SystemDrive.TrimEnd(':')
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($env:SystemDrive)'"
    $diskFreePct = if ($disk.Size -gt 0) { [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 1) } else { 0 }

    $diskQueuePath = "\LogicalDisk($systemDriveLetter`:)\Avg. Disk Queue Length"
    $diskQueueSample = Get-Counter $diskQueuePath
    $diskQueue = [math]::Round($diskQueueSample.CounterSamples[0].CookedValue, 2)

    $winsatXmlPath = "$env:WinDir\Performance\WinSAT\DataStore"
    $latestWinSat = Get-ChildItem -Path $winsatXmlPath -Filter "*Formal*.xml" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    $graphicsScore = $null
    $dwmScore = $null
    $winsatUsed = $false

    if ($latestWinSat) {
        try {
            [xml]$xml = Get-Content $latestWinSat.FullName
            $graphicsScore = [double]$xml.WinSAT.WinSPR.GraphicsScore
            $dwmScore      = [double]$xml.WinSAT.WinSPR.D3DScore
            $winsatUsed    = $true
        } catch { }
    }

    $cpuHealth       = Get-PercentScore -Value $cpuUsage    -GoodThreshold 20 -BadThreshold 90 -LowerIsBetter $true
    $memoryHealth    = Get-PercentScore -Value $usedMemPct  -GoodThreshold 50 -BadThreshold 95 -LowerIsBetter $true
    $diskFreeHealth  = Get-PercentScore -Value $diskFreePct -GoodThreshold 25 -BadThreshold 5  -LowerIsBetter $false
    $diskQueueHealth = Get-PercentScore -Value $diskQueue   -GoodThreshold 1  -BadThreshold 10 -LowerIsBetter $true

    if ($winsatUsed) {
        $graphicsHealth = [math]::Round(($graphicsScore / 9.9) * 100, 0)
        $dwmHealth      = [math]::Round(($dwmScore / 9.9) * 100, 0)
    } else {
        $graphicsHealth = 70
        $dwmHealth      = 70
    }

    $finalScore = [math]::Round((
        ($cpuHealth * 0.25) +
        ($memoryHealth * 0.25) +
        ($diskFreeHealth * 0.15) +
        ($diskQueueHealth * 0.15) +
        ($graphicsHealth * 0.10) +
        ($dwmHealth * 0.10)
    ), 0)

    $issues = @()
    if ($cpuUsage -ge 80) { $issues += "HighCPU" }
    if ($usedMemPct -ge 85) { $issues += "HighMemory" }
    if ($diskFreePct -le 10) { $issues += "LowDiskFree" }
    if ($diskQueue -ge 5) { $issues += "DiskBottleneck" }
    if ($winsatUsed -and $graphicsScore -lt 5.0) { $issues += "WeakGraphics" }
    if ($winsatUsed -and $dwmScore -lt 5.0) { $issues += "WeakDWM" }
    if ($issues.Count -eq 0) { $issues += "None" }

    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        TimeStamp    = (Get-Date).ToString("s")
        Score        = $finalScore
        Grade        = Get-Grade -Score $finalScore
        CPUPercent   = $cpuUsage
        MemoryUsedPct= $usedMemPct
        DiskFreePct  = $diskFreePct
        DiskQueue    = $diskQueue
        Issues       = ($issues -join ",")
    }
}

function Get-TrendStatus {
    param(
        [string]$HistoryPath,
        [int]$DeltaThreshold = 10
    )

    if (-not (Test-Path $HistoryPath)) {
        return [PSCustomObject]@{
            TrendStatus = "NoHistory"
            TrendDelta  = 0
        }
    }

    try {
        $history = Get-Content -Path $HistoryPath -Raw | ConvertFrom-Json
        if ($null -eq $history) {
            return [PSCustomObject]@{
                TrendStatus = "NoHistory"
                TrendDelta  = 0
            }
        }

        $items = @($history) | Sort-Object TimeStamp
        if ($items.Count -lt 6) {
            return [PSCustomObject]@{
                TrendStatus = "InsufficientHistory"
                TrendDelta  = 0
            }
        }

        $older3 = $items | Select-Object -Last 6 | Select-Object -First 3
        $newer3 = $items | Select-Object -Last 3

        $olderAvg = [math]::Round((($older3 | Measure-Object -Property Score -Average).Average), 1)
        $newerAvg = [math]::Round((($newer3 | Measure-Object -Property Score -Average).Average), 1)
        $delta = [math]::Round(($olderAvg - $newerAvg), 1)

        if ($delta -ge $DeltaThreshold) {
            return [PSCustomObject]@{
                TrendStatus = "TrendingWorse"
                TrendDelta  = $delta
            }
        } else {
            return [PSCustomObject]@{
                TrendStatus = "StableOrImproving"
                TrendDelta  = $delta
            }
        }
    }
    catch {
        return [PSCustomObject]@{
            TrendStatus = "HistoryReadError"
            TrendDelta  = 0
        }
    }
}

try {
    $result = Get-UiPerfAssessment
    $trend = Get-TrendStatus -HistoryPath $historyFile -DeltaThreshold $TrendDeltaThreshold

    $summary = "UIPerfScore=$($result.Score);Grade=$($result.Grade);CPU=$($result.CPUPercent);MemoryUsed=$($result.MemoryUsedPct);DiskFree=$($result.DiskFreePct);DiskQueue=$($result.DiskQueue);Issues=$($result.Issues);Trend=$($trend.TrendStatus);TrendDelta=$($trend.TrendDelta);Time=$($result.TimeStamp)"
    Write-Output $summary

    if ($result.Score -lt $ComplianceThreshold) {
        exit 1
    }

    if ($trend.TrendStatus -eq "TrendingWorse") {
        exit 1
    }

    exit 0
}
catch {
    Write-Output "UIPerfScore=0;Grade=F;Issues=AssessmentFailed;Trend=Unknown;Error=$($_.Exception.Message)"
    exit 1
}