# Define the display name to search for
$displayNameToSearch = "Poll Everywhere"

# Define the registry paths to search
$registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# Generate log file path in the user's home directory
$logFilePath = "C:\programdata\Microsoft\IntuneManagementExtension\Logs\PollEverywhere-Removal.log"


# Start transcript for logging
Start-Transcript -Path $logFilePath

# Loop through each registry path and search for the QuietUninstallString
foreach ($registryPath in $registryPaths) {
    Get-ItemProperty -Path $registryPath | ForEach-Object {
        if ($_.DisplayName -like "*$displayNameToSearch*") {
            $appName = $_.DisplayName
            $UninstallString = $_.UninstallString
            
            if ($UninstallString) {
                Write-Host "Poll Everywhere unistaller string found to be $UninstallString"
                Exit 1
                # Execute the uninstall command
                # & cmd /c $UninstallString /qn
                # Write-Host "$appName has been uninstalled."
            } else {
                Write-Host "No Poll Everywhere found for $appName on $(Get-Date)"
                Exit 0
            }
        }
    }
}

# Stop transcript
Stop-Transcript