param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $InputPath)) {
    throw "Input file not found: $InputPath"
}

function Get-ThermalZoneName {
    param([string]$Key)

    if ($Key -match '^(.*)\\(CurrentTemperatureF|CurrentTemperatureRaw)$') {
        return $Matches[1]
    }
    return $Key
}

$data = Import-Csv -LiteralPath $InputPath

$filtered = $data | Where-Object {
    $_.Source -eq 'MSAcpi_ThermalZoneTemperature' -and
    ($_.Key -like '*\CurrentTemperatureF' -or $_.Key -like '*\CurrentTemperatureRaw')
}

$grouped = $filtered | Group-Object {
    "$($_.Timestamp)|$(Get-ThermalZoneName $_.Key)"
}

$rows = foreach ($g in $grouped) {
    $first = $g.Group | Select-Object -First 1
    $zone  = Get-ThermalZoneName $first.Key

    $tempF = ($g.Group | Where-Object { $_.Key -like '*\CurrentTemperatureF' } | Select-Object -First 1).Value
    $tempR = ($g.Group | Where-Object { $_.Key -like '*\CurrentTemperatureRaw' } | Select-Object -First 1).Value

    [pscustomobject]@{
        Timestamp      = [datetime]$first.Timestamp
        Computer       = $first.Computer
        ThermalZone    = $zone
        TemperatureF   = if ($tempF -ne $null -and $tempF -ne '') { [double]$tempF } else { $null }
        TemperatureRaw = if ($tempR -ne $null -and $tempR -ne '') { [double]$tempR } else { $null }
    }
}

if (-not $rows) {
    throw "No matching thermal-zone temperature rows found in $InputPath"
}

$rows = $rows | Sort-Object Timestamp, ThermalZone

# Build wide chart data
$zones = $rows.ThermalZone | Sort-Object -Unique
$timestamps = $rows.Timestamp | Sort-Object -Unique

$chartRows = foreach ($ts in $timestamps) {
    $obj = [ordered]@{
        Timestamp = $ts
    }

    foreach ($zone in $zones) {
        $match = $rows | Where-Object { $_.Timestamp -eq $ts -and $_.ThermalZone -eq $zone } | Select-Object -First 1
        $obj[$zone] = if ($match) { $match.TemperatureF } else { $null }
    }

    [pscustomobject]$obj
}

$excel = $null
$workbook = $null
$wsRaw = $null
$wsNorm = $null
$wsChartData = $null

try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true
    $excel.DisplayAlerts = $false
    $excel.ScreenUpdating = $false

    $workbook = $excel.Workbooks.Add()

    # ---------------- RawImport ----------------
    $wsRaw = $workbook.Worksheets.Item(1)
    $wsRaw.Name = "RawImport"

    $headersRaw = @("Timestamp","Computer","Source","Key","Value")
    for ($c = 0; $c -lt $headersRaw.Count; $c++) {
        $wsRaw.Cells.Item(1, $c + 1).Value2 = $headersRaw[$c]
    }

    $r = 2
    foreach ($item in $data) {
        $wsRaw.Cells.Item($r,1).Value2 = $item.Timestamp
        $wsRaw.Cells.Item($r,2).Value2 = $item.Computer
        $wsRaw.Cells.Item($r,3).Value2 = $item.Source
        $wsRaw.Cells.Item($r,4).Value2 = $item.Key
        $wsRaw.Cells.Item($r,5).Value2 = $item.Value
        $r++
    }
    $wsRaw.Rows.Item(1).Font.Bold = $true
    $wsRaw.Columns("A:E").AutoFit() | Out-Null

    # ---------------- Normalized ----------------
    $wsNorm = $workbook.Worksheets.Add()
    $wsNorm.Name = "Normalized"

    $headersNorm = @("Timestamp","Computer","ThermalZone","TemperatureF","TemperatureRaw")
    for ($c = 0; $c -lt $headersNorm.Count; $c++) {
        $wsNorm.Cells.Item(1, $c + 1).Value2 = $headersNorm[$c]
    }

    $r = 2
    foreach ($item in $rows) {
        $wsNorm.Cells.Item($r,1).Value2 = $item.Timestamp
        $wsNorm.Cells.Item($r,2).Value2 = $item.Computer
        $wsNorm.Cells.Item($r,3).Value2 = $item.ThermalZone
        $wsNorm.Cells.Item($r,4).Value2 = $item.TemperatureF
        $wsNorm.Cells.Item($r,5).Value2 = $item.TemperatureRaw
        $r++
    }

    $lastNormRow = $rows.Count + 1
    $wsNorm.Rows.Item(1).Font.Bold = $true
    $wsNorm.Rows.Item(1).Interior.Color = 15921906
    $wsNorm.Columns("A").NumberFormat = "m/d/yyyy h:mm:ss AM/PM"
    $wsNorm.Columns("D:E").NumberFormat = "0.00"
    $wsNorm.Columns("A:E").AutoFit() | Out-Null
    $wsNorm.Range("A1:E$lastNormRow").AutoFilter() | Out-Null

    $tempRange = $wsNorm.Range("D2:D$lastNormRow")
    $formatCondition = $tempRange.FormatConditions.AddTop10()
    $formatCondition.Rank = 10
    $formatCondition.Percent = $false
    $formatCondition.Interior.Color = 13551615
    $formatCondition.Font.Bold = $true

    # ---------------- ChartData ----------------
    $wsChartData = $workbook.Worksheets.Add()
    $wsChartData.Name = "ChartData"

    $chartHeaders = @("Timestamp") + $zones
    for ($c = 0; $c -lt $chartHeaders.Count; $c++) {
        $wsChartData.Cells.Item(1, $c + 1).Value2 = $chartHeaders[$c]
    }

    $r = 2
    foreach ($row in $chartRows) {
        $wsChartData.Cells.Item($r,1).Value2 = $row.Timestamp
        for ($c = 0; $c -lt $zones.Count; $c++) {
            $wsChartData.Cells.Item($r, $c + 2).Value2 = $row.($zones[$c])
        }
        $r++
    }

    $lastChartRow = $chartRows.Count + 1
    $lastChartCol = $zones.Count + 1

    $wsChartData.Rows.Item(1).Font.Bold = $true
    $wsChartData.Rows.Item(1).Interior.Color = 15921906
    $wsChartData.Columns("A").NumberFormat = "m/d/yyyy h:mm:ss AM/PM"
    $wsChartData.Range($wsChartData.Cells.Item(2,2), $wsChartData.Cells.Item($lastChartRow,$lastChartCol)).NumberFormat = "0.00"
    $wsChartData.Columns.AutoFit() | Out-Null

    # ---------------- Create chart on Normalized ----------------
    $chartObject = $wsNorm.ChartObjects().Add(450, 10, 900, 400)
    $chart = $chartObject.Chart
    $chart.ChartType = 4  # xlLine

    $dataRange = $wsChartData.Range($wsChartData.Cells.Item(1,1), $wsChartData.Cells.Item($lastChartRow,$lastChartCol))
    $chart.SetSourceData($dataRange)
    $chart.HasTitle = $true
    $chart.ChartTitle.Text = "Thermal Zone Temperatures (F)"
    $chart.HasLegend = $true

    # Save
    $xlsxPath = [System.IO.Path]::ChangeExtension($InputPath, ".xlsx")
    $workbook.SaveAs($xlsxPath, 51)

    Write-Output "Formatted workbook with chart saved to: $xlsxPath"
}
finally {
    if ($workbook) { $workbook.Close($true) }
    if ($excel) {
        $excel.ScreenUpdating = $true
        $excel.DisplayAlerts = $true
        $excel.Quit()
    }

    foreach ($obj in @($wsChartData, $wsNorm, $wsRaw, $workbook, $excel)) {
        if ($obj) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($obj) }
    }

    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}