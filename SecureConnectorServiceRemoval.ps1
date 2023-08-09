### SecureConnector Service removal(SecureConnector) 06/16/2023
$serviceName = "SecureConnector"
# Check if the service is installed
$Today = Get-Date
$service = Get-WmiObject -Class Win32_Service -Filter "Name='SecureConnector'"
if ($service) {
    # Stop the service if it is running
    if ($service.Status -eq "Running") {
        Stop-Service -Name $serviceName
    }
    # Remove the service
    $service.delete()
    New-Item -Path "C:\Windows\Temp\SecureConnector-Removed.log" -Force -Verbose -ErrorAction SilentlyContinue
    Set-Content -Path "C:\Windows\Temp\SecureConnector-Removed.log" -Value "SecureConnector Service was removed for this system on $Today"
} else {
    New-Item -Path "C:\Windows\Temp\SecureConnector-NotFound.log" -Force -Verbose -ErrorAction SilentlyContinue
    Set-Content -Path "C:\Windows\Temp\SecureConnector-NotFound.log" -Value "SecureConnector Service was not found on this system on $Today"
}