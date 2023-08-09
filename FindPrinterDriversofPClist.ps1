$computers = Get-Content -Path "C:\jltools\listofcomputers.txt"
foreach ($computer in $computers) {
    $name = $computer
    Write-Host "Printers installed on $name" -ForegroundColor DarkMagenta
    Get-WmiObject -Class Win32_Printer -ComputerName $name |
        Select-Object Name, DriverName
}

#################
$computers = Get-Content "C:\jltools\listofcomputers.txt"

foreach ($computer in $computers) {
    try {
$printers = Get-WmiObject -Class Win32_Printer -ComputerName $name | Where-Object {$_.DriverName -eq "Universal Print Class Driver"}
 if ($printers) {
 Write-Output "Universal Printers not found on $computer"
Write-Output $printers
}
 else {
 }
    }
    catch {Write-Output "Error occurred while checking printers on $computer $_"
    
    #endregion
    }
}

################
$computers = Get-Content -Path "C:\jltools\listofcomputers.txt"
$driverName = "Universal Print Class Driver"
foreach ($computer in $computers) {
    $name = $computer
    if (Get-PrinterDriver -Name $driverName -ComputerName $name -ErrorAction SilentlyContinue) {
        Write-Host "$name has the $driverName driver installed." -ForegroundColor Green
    } else {
        Write-Host "$name is missing the $driverName driver." -ForegroundColor Red
        Get-WmiObject -Class Win32_ComputerSystem -ComputerName $name | 
            Select-Object Name
    }
}
########################
$computers = Get-Content -Path "C:\jltools\listofcomputers.txt"
$driverName = "Universal Print Class Driver"
$results = @()

foreach ($computer in $computers) {
    $name = $computer
    if (Get-PrinterDriver -Name $driverName -ComputerName $name -ErrorAction SilentlyContinue) {
        Write-Host "$name has the $driverName driver installed." -ForegroundColor Green
    } else {
        Write-Host "$name is missing the $driverName driver." -ForegroundColor Red
        $computerObject = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $name | 
            Select-Object Name
        $results += [PSCustomObject]@{
            ComputerName = $computerObject.Name
        }
    }
}

$results | Export-Csv -Path "C:\jltools\output.csv" -NoTypeInformation
