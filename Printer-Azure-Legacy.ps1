# Get all printers
$printers = Get-Printer

# Lists to hold names of printers
$legacyPrinters = @()
$azurePrintersCount = 0

foreach ($printer in $printers) {
    # Check if the printer's ComputerName contains legacy identifier or PortName contains Azure identifier
    if ($printer.ComputerName -like "*jlprnt-*") {
        $legacyPrinters += $printer.Name
    } elseif ($printer.PortName -like "*IPP-*") {
        $azurePrintersCount++
    }
}

# Construct the single line output
$output = "Azure Printers Count: $azurePrintersCount " + "| Legacy Printers Detected: " + ($legacyPrinters -join ', ') 

Write-Output $output

# Return exit codes based on detection
if ($legacyPrinters.Count -gt 0) {
    exit 1
} else {
    exit 0
}
