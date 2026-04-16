param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $CsvPath)) {
    throw "CSV not found: $CsvPath"
}

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $true
$excel.DisplayAlerts = $false
$excel.ScreenUpdating = $false

try {

    $workbook = $excel.Workbooks.Open($CsvPath)
    $worksheet = $workbook.Worksheets.Item(1)

    $worksheet.Columns("A").NumberFormat = "m/d/yyyy h:mm:ss AM/PM"

    $worksheet.Range("B2:FA724").NumberFormat = "0.00"

    $worksheet.Rows("3:721").Hidden = $true

    $worksheet.Cells.Item(723,1).Value2 = "Average (Formula)"
    $worksheet.Cells.Item(724,1).Value2 = "Average (Values)"

    for ($col = 2; $col -le 142; $col++) {

        $start = $worksheet.Cells.Item(2,$col).Address($false,$false)
        $end   = $worksheet.Cells.Item(722,$col).Address($false,$false)

        $formula = "=IF(COUNTA($start`:$end)=0,"""",AVERAGE($start`:$end))"

        $worksheet.Cells.Item(723,$col).Formula = $formula
    }

    $excel.Calculate()

    # Copy values from row 723 to 724
    $worksheet.Range("B724:FA724").Value2 = $worksheet.Range("B723:FA723").Value2

    # Format row 724
    $row724 = $worksheet.Range("A724:FA724")
    $row724.Font.Bold = $true
    $row724.Interior.Color = 16118015

    $worksheet.Columns("A:FA").AutoFit()

    $xlsx = [System.IO.Path]::ChangeExtension($CsvPath,".xlsx")
    $workbook.SaveAs($xlsx,51)

    Write-Output "Formatted workbook saved to: $xlsx"

}
finally {

    $workbook.Close($true)
    $excel.Quit()

    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}