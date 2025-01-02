# Define the path to the executable
$exePath = "C:\Program Files\ForeScout SecureConnector\SecureConnector.exe"

# Define the arguments for uninstallation
$arguments = "-uninstall -silent"

# Run the command using Start-Process
Start-Process -FilePath $exePath -ArgumentList $arguments -NoNewWindow -Wait
Write-Output "Successfully removed SecureConnector app"

