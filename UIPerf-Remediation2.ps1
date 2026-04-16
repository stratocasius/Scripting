# Intune Remediation Script - UI Performance with rolling file retention
# Writes logs to IME Logs root and keeps only the newest 10 .log and 10 .json files

$ErrorActionPreference = "SilentlyContinue"

$logRoot = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

$txtLog  = Join-Path $logRoot "UIPerf-$stamp.log"
$jsonLog = Join-Path $logRoot "UIPerf-$stamp.json"

$TrendDeltaThreshold = 10
$TrendHistoryCount = 6
$RetentionCount = 10

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
    }
    else {
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
        default       { "F" }
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
    $latestWinSat = Get-ChildItem -Path $winsatXmlPath -Filter "*Formal*.xml" -ErrorAction SilentlyContinue |
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
    }
    else {
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
        WinSATUsed    = $winsatUsed
        Issues        = @($issues)
    }
}

function Get-TrendSummaryFromJsonLogs {
    param(
        [string]$LogPath,
        [int]$DeltaThreshold = 10,
        [int]$HistoryCount = 6
    )

    try {
        $jsonFiles = Get-ChildItem -Path $LogPath -Filter "UIPerf-*.json" -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First $HistoryCount

        if (-not $jsonFiles -or $jsonFiles.Count -lt $HistoryCount) {
            return [PSCustomObject]@{
                TrendStatus  = "InsufficientHistory"
                OlderAverage = $null
                NewerAverage = $null
                Delta        = 0
                HistoryCount = if ($jsonFiles) { $jsonFiles.Count } else { 0 }
            }
        }

        $history = foreach ($file in ($jsonFiles | Sort-Object LastWriteTime)) {
            try {
                $obj = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
                [PSCustomObject]@{
                    TimeStamp = $obj.Current.TimeStamp
                    Score     = [double]$obj.Current.Score
                    FileName  = $file.Name
                }
            } catch { }
        }

        $history = @($history) | Where-Object { $null -ne $_.Score }

        if ($history.Count -lt $HistoryCount) {
            return [PSCustomObject]@{
                TrendStatus  = "InsufficientHistory"
                OlderAverage = $null
                NewerAverage = $null
                Delta        = 0
                HistoryCount = $history.Count
            }
        }

        $older3 = $history | Select-Object -First 3
        $newer3 = $history | Select-Object -Last 3

        $olderAvg = [math]::Round((($older3 | Measure-Object -Property Score -Average).Average), 1)
        $newerAvg = [math]::Round((($newer3 | Measure-Object -Property Score -Average).Average), 1)
        $delta = [math]::Round(($olderAvg - $newerAvg), 1)

        $status = if ($delta -ge $DeltaThreshold) { "TrendingWorse" } else { "StableOrImproving" }

        [PSCustomObject]@{
            TrendStatus  = $status
            OlderAverage = $olderAvg
            NewerAverage = $newerAvg
            Delta        = $delta
            HistoryCount = $history.Count
        }
    }
    catch {
        [PSCustomObject]@{
            TrendStatus  = "HistoryReadError"
            OlderAverage = $null
            NewerAverage = $null
            Delta        = 0
            HistoryCount = 0
        }
    }
}

function Remove-OldUIPerfFiles {
    param(
        [string]$LogPath,
        [int]$KeepCount = 10
    )

    $removed = @()

    $oldLogs = Get-ChildItem -Path $LogPath -Filter "UIPerf-*.log" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip $KeepCount

    foreach ($file in $oldLogs) {
        try {
            Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            $removed += $file.Name
        } catch { }
    }

    $oldJson = Get-ChildItem -Path $LogPath -Filter "UIPerf-*.json" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip $KeepCount

    foreach ($file in $oldJson) {
        try {
            Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            $removed += $file.Name
        } catch { }
    }

    return @($removed)
}

try {
    # Trend is based on the 6 prior JSON files already present
    $priorTrend = Get-TrendSummaryFromJsonLogs -LogPath $logRoot -DeltaThreshold $TrendDeltaThreshold -HistoryCount $TrendHistoryCount

    # Current run
    $result = Get-UiPerfAssessment

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
WinSAT Used   : $($result.WinSATUsed)
Issues        : $($result.Issues -join ",")

Prior Trend Status : $($priorTrend.TrendStatus)
Prior Older Avg    : $($priorTrend.OlderAverage)
Prior Newer Avg    : $($priorTrend.NewerAverage)
Prior Trend Delta  : $($priorTrend.Delta)
HistoryCountUsed   : $($priorTrend.HistoryCount)
==============================
"@ | Out-File -FilePath $txtLog -Encoding utf8 -Force

    $export = [PSCustomObject]@{
        Current = $result
        Trend   = $priorTrend
    }

    $export | ConvertTo-Json -Depth 5 | Out-File -FilePath $jsonLog -Encoding utf8 -Force

    $removedFiles = Remove-OldUIPerfFiles -LogPath $logRoot -KeepCount $RetentionCount

    Write-Output "UIPerfScore=$($result.Score);Grade=$($result.Grade);Trend=$($priorTrend.TrendStatus);TrendDelta=$($priorTrend.Delta);TrendHistoryCount=$TrendHistoryCount;Log=$txtLog;Json=$jsonLog;RemovedCount=$($removedFiles.Count)"
    exit 0
}
catch {
    Write-Output "UIPerf remediation failed: $($_.Exception.Message)"
    exit 1
}