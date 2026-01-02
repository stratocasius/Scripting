### ResearchMonitor Web Extension 3.6.1.629 - 03/10/2025
### Uninstall Script for ResearchMonitor Web Extension 3.6.1.629 if found.
### Establish transcript
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\RMWebExt2.4.6.418-Removal.log"
### Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\RMWebExt2.4.6.418-Removal.log"
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

        # Check if DisplayName contains "ResearchMonitor Web Extension Support Files - 2.4.6" and Publisher equals "Priory potenially"
        if ($displayName -and $uninstallString) {
            if ($displayName -match "ResearchMonitor Web Extension Support Files - 2.4.6") {
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
    Write-Host "Uninstall $uninstalledApps successful at $(get-Date)"
}
### Install of ResearchMonitor RMWeb Extension 3.6.1.629 installer
Set-Location -Path "C:\jltools\ResearchMonitor\RMWebExtension361"
$RMWebExt361 = "RMWebExtension_MSI-3.6.1.629.msi"
$RMWebExt361ARGs = "/I $RMWebExt246 /qn /l C:\programdata\microsoft\IntuneManagementExtension\Logs\RMWebExt361-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $RMWebExt246ARGs -wait -nonewwindow
Write-Output "ResearchMonitor Web Extension 3.6.1.629 install successfully on $(Get-Date)"
### Clean up Scheduled Task item.
Unregister-ScheduledTask -TaskName "RMWebExt361" -Confirm:$false
Write-Output "Removed RMWebExt361 from Task Scheduler"
### Clean up jltools folder
Set-Location -Path "C:\Windows\System32"
Remove-Item -Path "C:\jltools\ResearchMonitor\RMWebExtension361" -Force -Recurse
Remove-Item -Path "C:\jltools\ResearchMonitor" -Force -Recurse
Write-Output "Removed staging folder located at C:\jltools\ResearchMonitor"
Stop-Transcript