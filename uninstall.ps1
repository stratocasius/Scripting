# Define the display name to search for
$displayNameToSearch = "R for Windows"

# Define the registry paths to search
$registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Generate log file path in the user's home directory
$timestamp = Get-Date -Format "yyyyMMddHHmm"
$logFilePath = "C:\Windows\Temp\R-Uninstall-$timestamp.log"

# Start transcript for logging
Start-Transcript -Path $logFilePath

# Loop through each registry path and search for the QuietUninstallString
foreach ($registryPath in $registryPaths) {
    Get-ItemProperty -Path $registryPath | ForEach-Object {
        if ($_.DisplayName -like "*$displayNameToSearch*") {
            $appName = $_.DisplayName
            $quietUninstallString = $_.QuietUninstallString
            
            if ($quietUninstallString) {
                Write-Host "Original uninstall string: $quietUninstallString"
                
                # Replace /SILENT with /VERYSILENT if present
                if ($quietUninstallString -match "/SILENT") {
                    $quietUninstallString = $quietUninstallString -replace "/SILENT", "/VERYSILENT"
                    Write-Host "Modified uninstall string: $quietUninstallString"
                }
                
                Write-Host "Uninstalling $appName using $quietUninstallString"
                
                # Execute the uninstall command
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $quietUninstallString" -Wait

                Write-Host "$appName has been uninstalled."
            } else {
                Write-Host "No QuietUninstallString found for $appName"
            }
        }
    }
}

# Stop transcript
Stop-Transcript
