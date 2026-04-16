Sub FormatCoolingSuperLean_WithChart()

    Dim filePath As Variant
    Dim wb As Workbook
    Dim wsRaw As Worksheet
    Dim wsNorm As Worksheet
    Dim wsChart As Worksheet
    Dim lastRow As Long
    Dim outRow As Long
    Dim i As Long
    Dim dict As Object
    Dim ts As String, comp As String, src As String, ky As String, val As String
    Dim zone As String, groupKey As String
    Dim arr, k
    Dim tempLastRow As Long
    Dim zoneDict As Object, tsDict As Object
    Dim zoneList() As String
    Dim tsList() As String
    Dim r As Long, c As Long
    Dim chartObj As ChartObject
    Dim dataRange As Range
    Dim zoneIndex As Long

    filePath = Application.GetOpenFilename("Log/CSV Files (*.log;*.csv), *.log;*.csv")
    If filePath = False Then Exit Sub

    Application.ScreenUpdating = False
    Application.DisplayAlerts = False

    Set wb = Workbooks.Open(filePath)
    Set wsRaw = wb.Worksheets(1)
    wsRaw.Name = "RawImport"

    lastRow = wsRaw.Cells(wsRaw.Rows.Count, 1).End(xlUp).Row

    Set wsNorm = wb.Worksheets.Add(After:=wsRaw)
    wsNorm.Name = "Normalized"
    wsNorm.Range("A1:E1").Value = Array("Timestamp", "Computer", "ThermalZone", "TemperatureF", "TemperatureRaw")
    wsNorm.Rows(1).Font.Bold = True

    Set dict = CreateObject("Scripting.Dictionary")
    Set zoneDict = CreateObject("Scripting.Dictionary")
    Set tsDict = CreateObject("Scripting.Dictionary")

    ' Build normalized records
    For i = 2 To lastRow
        src = Trim(wsRaw.Cells(i, 3).Value)
        ky = Trim(wsRaw.Cells(i, 4).Value)

        If src = "MSAcpi_ThermalZoneTemperature" Then
            If Right(ky, 20) = "\CurrentTemperatureF" Or Right(ky, 22) = "\CurrentTemperatureRaw" Then

                ts = wsRaw.Cells(i, 1).Value
                comp = wsRaw.Cells(i, 2).Value
                val = wsRaw.Cells(i, 5).Value

                zone = ky
                zone = Replace(zone, "\CurrentTemperatureF", "")
                zone = Replace(zone, "\CurrentTemperatureRaw", "")

                groupKey = CStr(ts) & "|" & zone

                If Not dict.Exists(groupKey) Then
                    ReDim arr(1 To 5)
                    arr(1) = ts
                    arr(2) = comp
                    arr(3) = zone
                    arr(4) = ""
                    arr(5) = ""
                Else
                    arr = dict(groupKey)
                End If

                If Right(ky, 20) = "\CurrentTemperatureF" Then arr(4) = val
                If Right(ky, 22) = "\CurrentTemperatureRaw" Then arr(5) = val

                dict(groupKey) = arr

                If Not zoneDict.Exists(zone) Then zoneDict.Add zone, zone
                If Not tsDict.Exists(CStr(ts)) Then tsDict.Add CStr(ts), ts
            End If
        End If
    Next i

    ' Write normalized output
    outRow = 2
    For Each k In dict.Keys
        arr = dict(k)
        wsNorm.Cells(outRow, 1).Value = arr(1)
        wsNorm.Cells(outRow, 2).Value = arr(2)
        wsNorm.Cells(outRow, 3).Value = arr(3)
        wsNorm.Cells(outRow, 4).Value = arr(4)
        wsNorm.Cells(outRow, 5).Value = arr(5)
        outRow = outRow + 1
    Next k

    tempLastRow = wsNorm.Cells(wsNorm.Rows.Count, 1).End(xlUp).Row
    wsNorm.Columns("A").NumberFormat = "m/d/yyyy h:mm:ss AM/PM"
    wsNorm.Columns("D:E").NumberFormat = "0.00"
    wsNorm.Range("A1:E1").Interior.Color = RGB(218, 233, 248)
    wsNorm.Columns("A:E").AutoFit
    wsNorm.Range("A1:E" & tempLastRow).AutoFilter

    ' Highlight top 10 temperatures
    With wsNorm.Range("D2:D" & tempLastRow)
        .FormatConditions.Delete
        With .FormatConditions.AddTop10
            .TopBottom = xlTop10Top
            .Rank = 10
            .Interior.Color = RGB(255, 230, 153)
            .Font.Bold = True
        End With
    End With

    ' Create ChartData sheet
    Set wsChart = wb.Worksheets.Add(After:=wsNorm)
    wsChart.Name = "ChartData"

    ReDim zoneList(1 To zoneDict.Count)
    zoneIndex = 1
    For Each k In zoneDict.Keys
        zoneList(zoneIndex) = k
        zoneIndex = zoneIndex + 1
    Next k

    wsChart.Cells(1, 1).Value = "Timestamp"
    For c = 1 To UBound(zoneList)
        wsChart.Cells(1, c + 1).Value = zoneList(c)
    Next c

    r = 2
    For Each k In tsDict.Keys
        wsChart.Cells(r, 1).Value = tsDict(k)

        For c = 1 To UBound(zoneList)
            Dim foundVal As Variant
            foundVal = ""
            For i = 2 To tempLastRow
                If CStr(wsNorm.Cells(i, 1).Value) = CStr(tsDict(k)) And _
                   CStr(wsNorm.Cells(i, 3).Value) = zoneList(c) Then
                    foundVal = wsNorm.Cells(i, 4).Value
                    Exit For
                End If
            Next i
            wsChart.Cells(r, c + 1).Value = foundVal
        Next c

        r = r + 1
    Next k

    wsChart.Rows(1).Font.Bold = True
    wsChart.Range("A1").EntireRow.Interior.Color = RGB(218, 233, 248)
    wsChart.Columns("A").NumberFormat = "m/d/yyyy h:mm:ss AM/PM"
    wsChart.Columns.AutoFit

    ' Create line chart on Normalized sheet
    Set chartObj = wsNorm.ChartObjects.Add(Left:=450, Top:=10, Width:=900, Height:=400)
    chartObj.Chart.ChartType = xlLine

    Set dataRange = wsChart.Range(wsChart.Cells(1, 1), wsChart.Cells(r - 1, zoneDict.Count + 1))
    chartObj.Chart.SetSourceData Source:=dataRange
    chartObj.Chart.HasTitle = True
    chartObj.Chart.ChartTitle.Text = "Thermal Zone Temperatures (F)"
    chartObj.Chart.HasLegend = True

    Application.ScreenUpdating = True
    Application.DisplayAlerts = True

    MsgBox "Cooling System super-lean log formatted and chart created successfully.", vbInformation

End Sub