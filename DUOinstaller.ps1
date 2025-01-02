# Registry paths for Uninstall keys
$regPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# Check the registry for Duo installation
$duoInstalled = $false
foreach ($path in $regPaths) {
    $duoEntry = Get-ItemProperty $path | Where-Object { $_.DisplayName -eq "Duo Authentication for Windows Logon x64" }
    if ($duoEntry) {
        $duoInstalled = $true
        break
    }
}

if (-not $duoInstalled) {
    Write-Output "Duo not found or version is incorrect"
    exit 1
}
exit 0



########################################
### Rememdiation
########################################
$ProgressPreference = 'SilentlyContinue'
# Define the URL and the destination path
$url = "https://dl.duosecurity.com/duo-win-login-latest.exe"
$destination = "C:\temp\duo-win-login.exe"

# Create the destination directory if it doesn't exist
if (-not (Test-Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}

# Download the file
Invoke-WebRequest -Uri $url -OutFile $destination

# Check the file size
$fileSize = (Get-Item $destination).Length
$minimumSize = 4MB  # 4 Megabytes

if ($fileSize -lt $minimumSize) {
    Write-Output "Unexpected file size. Exiting"
    exit 1
}

# Define installation arguments
$installArgs = '/S /V" IKEY="DICEDQG0JV3MHHWEZMXS" SKEY="JSXwfNEV707sUq2P2qvBLkjyASaPCQLRBCZHqEYo" HOST="api-85a5eb34.duosecurity.com" AUTOPUSH="1" FAILOPEN="1" RDPONLY="0" /qn /l*v! C:\Windows\Temp\DUOWinLoginCurrent-INSTALL.log"'

# Install the application
Start-Process -FilePath $destination -Args $installArgs -Wait -NoNewWindow

# Clean up: Delete the installer file
Remove-Item -Path $destination

# Registry paths for Uninstall keys
$regPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# Check the registry for Duo installation
$duoInstalled = $false
foreach ($path in $regPaths) {
    $duoEntry = Get-ItemProperty $path | Where-Object { $_.DisplayName -eq "Duo Authentication for Windows Logon x64" }
    if ($duoEntry) {
        $duoInstalled = $true
        Write-Output "$($duoEntry.DisplayName) $($duoEntry.DisplayVersion) Installed"
        exit 0
    }
}

if (-not $duoInstalled) {
    Write-Output "Duo not found"
    exit 1
}
