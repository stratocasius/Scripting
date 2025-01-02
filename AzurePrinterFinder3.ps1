# Get a list of shared printers on the local computer
$sharedPrinters = Get-WmiObject -Query "SELECT * FROM Win32_Printer WHERE Shared=True"

# Loop through the shared printers and display share name and server
foreach ($printer in $sharedPrinters) {
    $shareName = $printer.Name
    $serverName = $printer.ServerName

    Write-Host "Shared Printer Name: $shareName"
    Write-Host "Server Name: $serverName"
    Write-Host "-------------------------"
}