$computers = Get-Content -Path C:\jltools\listofComputers.txt
$results = @()

foreach ($computer in $computers) {
    try {
        $thermalZone = Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_ThermalZoneTemperature -ComputerName LT5825
        $temperature = ($thermalZone.CurrentTemperature / 10) - 273.15
        $result = [PSCustomObject]@{
            ComputerName = $computer
            Temperature = $temperature
            TimeStamp = Get-Date
        }
        $results += $result
    } catch {
        Write-Host "Failed to retrieve temperature from $computer. Error: $_" -ForegroundColor Red
    }
}

$results | Export-Csv -Path C:\jltools\Temperature.csv -NoTypeInformation



################ Combine with below:
# Get a list of computers from a text file
$computers = Get-Content -Path "C:\Computers.txt"

# Loop through each computer and enable PSRemoting
foreach ($computer in $computers) {
    # Test if the computer is online and accessible
    if (Test-Connection -ComputerName $computer -Quiet) {
        # Enable PSRemoting on the remote computer
        Invoke-Command -ComputerName $computer -ScriptBlock {
            Enable-PSRemoting -Force
        }
        Write-Host "PSRemoting enabled on $computer." -ForegroundColor Green
    } else {
        Write-Host "Could not connect to $computer." -ForegroundColor Red
    }
}