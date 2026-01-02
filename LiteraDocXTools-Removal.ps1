### Metadact removal and file backup to C:\jltools\MetadactCustomFiles - 05/03/2024
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'Litera DocXTools (64-bit)'" call uninstall > C:\Windows\Temp\LiteraDocXTools-Removal.log



### Uninstall Script for Teamviewer 
### Establish transcript
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\Teamviewer-Removal.log"
### Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\Teamviewer-Removal.log"
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

        # Check if DisplayName contains "TeamViewer" and Publisher equals "Teamviewer potenially"
        if ($displayName -and $uninstallString) {
            if ($displayName -match "Litera DocXTools (64-bit)") {
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
Stop-Transcript