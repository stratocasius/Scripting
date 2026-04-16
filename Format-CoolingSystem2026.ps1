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

    # Example key:
    # ACPI\MSHW0188\1_0\CurrentTemperatureF
    if ($Key -match '^(.*)\\(CurrentTemperatureF|CurrentTemperatureRaw)$') {
        return $Matches[1]
    }
    return $Key
}

# ------------------------------------------------------------
# Read and normalize source data
# ------------------------------------------------------------
$data = Import-Csv -LiteralPath $InputPath

# Keep only useful rows
$filtered = $data | Where-Object {
    $_.Source -eq 'MSAcpi_ThermalZoneTemperature' -and
    ($_.Key -like '*\CurrentTemperatureF' -or $_.Key -like '*\CurrentTemperatureRaw')
}

# Group by Timestamp + Thermal Zone
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

# Sort cleanly
$rows = $rows | Sort-Object Timestamp, ThermalZone

# ------------------------------------------------------------
# Open Excel and write normalized workbook
# ------------------------------------------------------------
$excel = $null
$workbook = $null
$wsRaw = $null
$wsNorm = $null

try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true
    $excel.DisplayAlerts = $false
    $excel.ScreenUpdating = $false

    $workbook = $excel.Workbooks.Add()

    $wsRaw = $workbook.Worksheets.Item(1)
    $wsRaw.Name = "RawImport"

    # Write raw imported data
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

    # Add normalized sheet
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

    $lastRow = $rows.Count + 1

    # Formatting
    $wsNorm.Rows.Item(1).Font.Bold = $true
    $wsNorm.Rows.Item(1).Interior.Color = 15921906
    $wsNorm.Columns("A").NumberFormat = "m/d/yyyy h:mm:ss AM/PM"
    $wsNorm.Columns("D:E").NumberFormat = "0.00"
    $wsNorm.Columns("A:E").AutoFit() | Out-Null

    # Freeze top row
    $excel.ActiveWindow.SplitRow = 1
    $excel.ActiveWindow.FreezePanes = $true

    # --------------------------------------------------------
    # Highlight top 10 highest TemperatureF values
    # --------------------------------------------------------
    $tempRange = $wsNorm.Range("D2:D$lastRow")
    $formatCondition = $tempRange.FormatConditions.AddTop10()
    $formatCondition.Rank = 10
    $formatCondition.Percent = $false
    $formatCondition.Interior.Color = 13551615
    $formatCondition.Font.Bold = $true

    # Add autofilter
    $wsNorm.Range("A1:E$lastRow").AutoFilter() | Out-Null

    # Save as xlsx
    $xlsxPath = [System.IO.Path]::ChangeExtension($InputPath, ".xlsx")
    $workbook.SaveAs($xlsxPath, 51)

    Write-Output "Formatted workbook saved to: $xlsxPath"
}
finally {
    if ($workbook) { $workbook.Close($true) }
    if ($excel) {
        $excel.ScreenUpdating = $true
        $excel.DisplayAlerts = $true
        $excel.Quit()
    }

    if ($wsNorm) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsNorm) }
    if ($wsRaw)  { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsRaw) }
    if ($workbook) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook) }
    if ($excel) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) }

    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}