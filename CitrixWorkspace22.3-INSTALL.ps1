# Define paths and commands
$RemovalCommand = "C:\ProgramData\Citrix\Citrix Workspace 1912\TrolleyExpress.exe /uninstall /silent"
$InstallCommand = "CitrixWorkspaceApp22.3.exe /noreboot /silent ALLOWSAVEPWD=A ALLOWADDSTORE=A /includeSSON /ENABLE_SSON=Yes /AutoUpdateCheck=disabled EnableCEIP=false STORE0=`"XenDesktop;https://citrix.jacksonlewis.com/Citrix/XenDesktop/discovery;On;Citrix XenDesktop Store`""
$LogFile = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\CitrixWorkspace-INSTALL.log"

# Start logging
Start-Transcript -Path $LogFile -Append
Write-Output "Starting Citrix Workspace 1912 removal and upgrade process."

# Check if Citrix Workspace 1912 exists before attempting removal
if (Test-Path "C:\ProgramData\Citrix\Citrix Workspace 1912\TrolleyExpress.exe") {
    Write-Output "Citrix Workspace 1912 found. Proceeding with removal."
    Invoke-Expression $RemovalCommand
    Write-Output "Citrix Workspace 1912 removal command executed."
} else {
    Write-Output "Citrix Workspace 1912 not found. Skipping removal."
}

# Wait for a few seconds to ensure removal completes
Start-Sleep -Seconds 10

# Install the new Citrix Workspace
Write-Output "Starting Citrix Workspace installation."
Invoke-Expression $InstallCommand
Write-Output "Citrix Workspace installation command executed."

# Stop logging
Stop-Transcript
Write-Output "Citrix Workspace upgrade process completed. Logs saved to $LogFile."