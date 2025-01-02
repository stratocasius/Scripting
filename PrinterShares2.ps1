######### Another Option
# Get the username of the current user
$currentUsername = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Query the Win32_Printer class to retrieve printer network configurations
$printers = Get-WmiObject -Class Win32_Printer | Where-Object {$_.Network -eq $true -and $_.Local -eq $false}

# Filter printers for the current user
$printersForCurrentUser = $printers | Where-Object {$_.Location -like "*$currentUsername*"}

# Display printer network configurations
foreach ($printer in $printersForCurrentUser) {
    Write-Host "Printer Name: $($printer.Name)"
    Write-Host "Location: $($printer.Location)"
    Write-Host "Port Name: $($printer.PortName)"
    Write-Host "Network Path: $($printer.HostName)"
    Write-Host ""
}
