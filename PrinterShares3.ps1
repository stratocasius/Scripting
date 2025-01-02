######### Another Option
# Get the username of the current user
$currentUsername = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Query the Win32_Printer class to retrieve printer network configurations
$printers = Get-WmiObject -Class Win32_Printer | Where-Object {$_.Network -eq $true -and $_.Local -eq $false}
    Write-Host "Printer name: $($printers)"