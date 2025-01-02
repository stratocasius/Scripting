# Suppress the progress bar
$ProgressPreference = 'SilentlyContinue'

# Set ErrorActionPreference
$ErrorActionPreference = "Stop"

# URL and destination path
$url = "https://jlgeneralstorage.blob.core.windows.net/endpoint/TeamViewer_Host.msi"
$dest = "C:\Temp\TeamViewer_Host.msi"

# Download TeamViewer
Invoke-WebRequest -Uri $url -OutFile $dest

# Check file size
$fileSize = (Get-Item $dest).length / 1MB
if ($fileSize -lt 10) {
    Write-Error "Downloaded TeamViewer file is less than 10 MB."
    exit 1
}

function CheckTeamViewer {
    param (
        [string]$regPath
    )

    return Get-ChildItem $regPath -ErrorAction SilentlyContinue | 
           Get-ItemProperty | 
           Where-Object { $_.DisplayName -like "*TeamViewer*" }
}

# Check if TeamViewer is already installed
$regPath32 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
$regPath64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"

$teamviewer = CheckTeamViewer -regPath $regPath32
if (-not $teamviewer) {
    $teamviewer = CheckTeamViewer -regPath $regPath64
}

if ($teamviewer) {
    Write-Host "TeamViewer is already installed. Uninstalling..."
    # Uninstall using the UninstallString
    $uninstallString = $teamviewer.UninstallString
    Start-Process cmd -ArgumentList "/c $uninstallString /quiet /norestart" -Wait
}

# Install the new TeamViewer with the provided arguments
$installArgs = "/I $dest /qn CUSTOMCONFIGID=6gt8mb3 APITOKEN=16621801-TN3BCQXdDOAjbSLrq3C0 ASSIGNMENTOPTIONS=""--grant-easy-access --reassign --group-id g245550865"" /norestart /l C:\Windows\Temp\TeamViewer15.37.3.0-INSTALL.log"
Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait

# Re-check if TeamViewer is installed
$teamviewerPostInstall = CheckTeamViewer -regPath $regPath32
if (-not $teamviewerPostInstall) {
    $teamviewerPostInstall = CheckTeamViewer -regPath $regPath64
}

if ($teamviewerPostInstall) {
    Write-Host "TeamViewer has been re-installed. Version: $($teamviewerPostInstall.DisplayVersion)"
    exit 0
} else {
    Write-Error "TeamViewer installation failed."
    exit 1
}