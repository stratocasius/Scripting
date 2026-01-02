### Uninstall Script for Litera Compare 11.12 Removal - 05/03/2025
### Establish transcript
# Track script start time (before anything else happens)
$global:ScriptStartTime = Get-Date
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\Compare11.12-Removal.log"
### Start logging
Start-Transcript -Path $logFilepath -Append
# Initialize an empty array to store uninstalled applications
$uninstalledApps = @()

# Define the uninstall registry paths for both 32-bit and 64-bit applications
$uninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Loop through each uninstall path
foreach ($path in $uninstallPaths) {
    # Get all subkeys (each representing an installed application)
    Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
        $appKey = $_.PSPath
        $displayName = (Get-ItemProperty -Path $appKey -Name DisplayName -ErrorAction SilentlyContinue).DisplayName
        $displayVersion = (Get-ItemProperty -Path $appKey -Name DisplayVersion -ErrorAction SilentlyContinue).DisplayVersion
        $uninstallString = (Get-ItemProperty -Path $appKey -Name UninstallString -ErrorAction SilentlyContinue).UninstallString

        # Check if DisplayName contains "Compare11.12" and Publisher equals "Compare 11.12 potenially"
        if ($displayName -and $uninstallString) {
            if ($displayName -match "Litera Compare") {
                # Uninstall the application using the UninstallString
                try {
                    # Prepare the uninstall command
                    $cmd = $uninstallString

                    # Adjust MSI uninstall commands if necessary
                    if ($cmd -match "MsiExec\.exe\s+/I") {
                        $cmd = $cmd -replace "/I", "/X"
                    }

                    # Add silent uninstall parameters if not already present
                    if ($cmd -notmatch "/qn") {
                        $cmd += " /qn"
                    }

                    # Execute the uninstall command
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -Wait -NoNewWindow -Verbose
                    Write-Host "Uninstall started at $(get-Date)"
                }
                catch {
                    Write-Error "Failed to uninstall $displayName : $_"
                    Write-Host "Uninstall failed on $(get-Date)"
                }

                # Add the DisplayName and DisplayVersion to the array
                $uninstalledApps += "$displayName $displayVersion"
            }
        }
    }
}

# If any applications were uninstalled, write them out
if ($uninstalledApps.Count -gt 0) {
    # Write out all uninstalled applications on a single line
    Write-Output ($uninstalledApps -join ", ")
    Write-Host "Uninstall $uninstalledApps at $(get-Date)"
}
# Capture and calculate script runtime
# Calculate duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("Litera Compare Removal script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
Stop-Transcript