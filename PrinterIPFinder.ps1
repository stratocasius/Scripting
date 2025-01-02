Get-WmiObject -Query "SELECT * FROM Win32_Printer" | ForEach-Object {
    if ($_.PortName -like "*IP_*") {
        $printerName = $_.Name
        $ipAddress = $_.PortName -replace '.*(\d+\.\d+\.\d+\.\d+).*', '$1'
        Write-Output "Printer Name: $printerName, IP Address: $ipAddress"
    }
}