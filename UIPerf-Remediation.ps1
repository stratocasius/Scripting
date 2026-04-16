### UI Performance with rolling history - 03/18/2026
# Writes logs to IME Logs folder for diagnostics collection

$ErrorActionPreference = "SilentlyContinue"

$logRoot = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

$txtLog      = Join-Path $logRoot "UIPerf-$stamp.log"
$jsonLog     = Join-Path $logRoot "UIPerf-$stamp.json"
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
    $diskFreeGB = [math]::Round(($disk.FreeSpace / 1GB), 2)
    $diskSizeGB = [math]::Round(($disk.Size / 1GB), 2)
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
        ComputerName  = $env:COMPUTERNAME
        TimeStamp     = (Get-Date).ToString("s")
        Score         = $finalScore
        Grade         = Get-Grade -Score $finalScore
        CPUPercent    = $cpuUsage
        MemoryUsedPct = $usedMemPct
        TotalMemoryGB = $totalMemGB
        FreeMemoryGB  = $freeMemGB
        DiskFreePct   = $diskFreePct
        DiskFreeGB    = $diskFreeGB
        DiskSizeGB    = $diskSizeGB
        DiskQueue     = $diskQueue
        GraphicsScore = $graphicsScore
        DWMScore      = $dwmScore
        Issues        = @($issues)
    }
}

function Update-History {
    param(
        [string]$HistoryPath,
        [object]$NewResult,
        [int]$KeepLast = 10
    )

    $history = @()

    if (Test-Path $HistoryPath) {
        try {
            $existing = Get-Content -Path $HistoryPath -Raw | ConvertFrom-Json
            if ($existing) {
                $history = @($existing)
            }
        } catch { }
    }

    $history += [PSCustomObject]@{
        TimeStamp = $NewResult.TimeStamp
        ComputerName = $NewResult.ComputerName
        Score = $NewResult.Score
        Grade = $NewResult.Grade
        Issues = ($NewResult.Issues -join ",")
    }

    $history = $history | Sort-Object TimeStamp | Select-Object -Last $KeepLast
    $history | ConvertTo-Json -Depth 3 | Out-File -FilePath $HistoryPath -Encoding utf8 -Force

    return ,$history
}

function Get-TrendSummary {
    param([array]$History)

    $items = @($History) | Sort-Object TimeStamp
    if ($items.Count -lt 6) {
        return [PSCustomObject]@{
            TrendStatus = "InsufficientHistory"
            OlderAverage = $null
            NewerAverage = $null
            Delta = 0
        }
    }

    $older3 = $items | Select-Object -Last 6 | Select-Object -First 3
    $newer3 = $items | Select-Object -Last 3

    $olderAvg = [math]::Round((($older3 | Measure-Object -Property Score -Average).Average), 1)
    $newerAvg = [math]::Round((($newer3 | Measure-Object -Property Score -Average).Average), 1)
    $delta = [math]::Round(($olderAvg - $newerAvg), 1)

    $status = if ($delta -ge 10) { "TrendingWorse" } elseif ($delta -le -5) { "Improving" } else { "Stable" }

    [PSCustomObject]@{
        TrendStatus = $status
        OlderAverage = $olderAvg
        NewerAverage = $newerAvg
        Delta = $delta
    }
}

try {
    $result = Get-UiPerfAssessment
    $history = Update-History -HistoryPath $historyFile -NewResult $result -KeepLast 10
    $trend = Get-TrendSummary -History $history

    @"
==============================
UI Performance Assessment
==============================
Computer Name : $($result.ComputerName)
Timestamp     : $($result.TimeStamp)
Score         : $($result.Score)
Grade         : $($result.Grade)

CPU Usage     : $($result.CPUPercent) %
Memory Used   : $($result.MemoryUsedPct) %
Disk Free     : $($result.DiskFreePct) %
Disk Queue    : $($result.DiskQueue)

Graphics Score: $($result.GraphicsScore)
DWM Score     : $($result.DWMScore)
Issues        : $($result.Issues -join ",")

History File  : $historyFile
Trend Status  : $($trend.TrendStatus)
Older Avg     : $($trend.OlderAverage)
Newer Avg     : $($trend.NewerAverage)
Trend Delta   : $($trend.Delta)
==============================
"@ | Out-File -FilePath $txtLog -Encoding utf8 -Force

    $export = [PSCustomObject]@{
        Current = $result
        Trend   = $trend
        History = $history
    }

    $export | ConvertTo-Json -Depth 5 | Out-File -FilePath $jsonLog -Encoding utf8 -Force

    Write-Output "UIPerfScore=$($result.Score);Grade=$($result.Grade);Trend=$($trend.TrendStatus);TrendDelta=$($trend.Delta);Log=$txtLog;History=$historyFile"
    exit 0
}
catch {
    Write-Output "UIPerf remediation failed: $($_.Exception.Message)"
    exit 1
}