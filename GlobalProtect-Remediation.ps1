# Ensure the temp directory exists
$downloadPath = "C:\temp\GlobalProtect64-6.1.4.msi"
If (-not (Test-Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}

# Download the file
Invoke-WebRequest -Uri "https://jlgeneralstorage.blob.core.windows.net/endpoint/GlobalProtect64-6.1.4.msi" -OutFile $downloadPath

# Check the file size
$fileSize = (Get-Item $downloadPath).length / 1MB
If ($fileSize -lt 10) {
    Write-Output "Unexpected file size, exiting"
    Exit 1
}

# Kill MSIexec if running
Stop-Process -Name "msiexec" -Force -ErrorAction SilentlyContinue

# Install the MSI
$installArgs = 'PORTAL=jlvpn.gpcloudservice.com CONNECTMETHOD=pre-logon PRELOGON=1 EXTCERTOID=1.3.6.1.4.1.311.21.8.12699277.13079172.10503332.10842942.11634168.37.4702739.3779210 CERTIFICATESTORELOOKUP=machine /qn /l*v c:\windows\temp\GlobalProtect-6.1.4-INSTALL.log /norestart'
Start-Process "msiexec.exe" -ArgumentList "/i `"$downloadPath`" $installArgs" -Wait
start-sleep 60

# Clean up the MSI file
Remove-Item -Path $downloadPath
