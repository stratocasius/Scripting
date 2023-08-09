### ForeScout Service removal(fsprocsvc) 06/15/2023
$serviceName = "fsprocsvc"
# Check if the service is installed
$Today = Get-Date
$service = Get-WmiObject -Class Win32_Service -Filter "Name='fsprocsvc'"
if ($service) {
    # Stop the service if it is running
    if ($service.Status -eq "Running") {
        Stop-Service -Name $serviceName
    }
    # Remove the service
    $service.delete()
    New-Item -Path "C:\Windows\Temp\ForeScoutProcess-Removed.log" -Force -Verbose -ErrorAction SilentlyContinue
    Set-Content -Path "C:\Windows\Temp\ForeScoutProcess-Removed.log" -Value "ForeScout Service was removed for this system on $Today"
} else {
    New-Item -Path "C:\Windows\Temp\ForeScoutProcess-NotFound.log" -Force -Verbose -ErrorAction SilentlyContinue
    Set-Content -Path "C:\Windows\Temp\ForeScoutProcess-NotFound.log" -Value "ForeScout Service was not found on this system on $Today"
}