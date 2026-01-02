### Uninstall Script for ExpertOutlookAddin 
### Establish transcript
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\ExpertOutlookAddin-Removal.log"
### Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\ExpertOutlookAddin-Removal.log"
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

        # Check if DisplayName contains "ExpertOutlookAddin" and Publisher equals "ExpertOutlookAddin potenially"
        if ($displayName -and $uninstallString) {
            if ($displayName -match "Aderant.Expert.Outlook.Addin") {
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

# Define the target registry path based on the provided .reg file
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\jacksonlewis.net\adrliveapps"

# Check if the registry path exists; if it does, delete it
if (Test-Path -Path $registryPath) {
    Remove-Item -Path $registryPath -Recurse -Force
    Write-Output "The registry key $registryPath has been deleted."
} else {
    Write-Output "The registry key $registryPath does not exist."
}
Stop-Transcript