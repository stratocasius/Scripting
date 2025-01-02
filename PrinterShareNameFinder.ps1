# Query the Win32_Printer class to retrieve printer information
$printers = Get-WmiObject -Class Win32_Printer

# Iterate through the printer objects and display printer names and share names
foreach ($printer in $printers) {
      $shareName = $printer.ShareName
      $systemName = $printer.Name
    
    Write-Host "Share Name: $SystemName"
    Write-Host "Share Path: $shareName"
    Write-Host ""
}