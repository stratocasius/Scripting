### Eclipse Temurin JRE with Hotspot 8u422-b05 (x64) - 10/17/2024
### Replacement solution for Oracle's Java and supplies updated "helper.bat" to Intapp's Integration Builder(JL Finance Team)
# Define the MSI installer path and the log file path
$msiInstallerPath = "OpenJDK8U-jre_x64_windows_hotspot_8u422b05.msi"
$logFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\OpenJDK8u422-INSTALL.log"

# Run the MSI installer with the specified parameters
Start-Process "msiexec.exe" -ArgumentList "/i `"$msiInstallerPath`" ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith /qn /l*v `"$logFilePath`"" -Wait -NoNewWindow

# Define the target directory path and helper.bat file paths
$targetPath = "C:\Program Files (x86)\Intapp\Integration Builder"
$helperSourcePath = "helper.bat"
$helperTargetPath = "$targetPath\helper.bat"

# Check if the target directory exists
if (Test-Path -Path $targetPath) {
    # Check if the source helper.bat file exists
    if (Test-Path -Path $helperSourcePath) {
        try {
            # Copy the helper.bat file to the target directory, overwrite if it exists
            Copy-Item -Path $helperSourcePath -Destination $helperTargetPath -Force
            Write-Output "helper.bat successfully copied to $helperTargetPath."
        } catch {
            Write-Output "Error: Failed to copy helper.bat. $_"
        }
    } else {
        Write-Output "Error: helper.bat file not found at $helperSourcePath."
    }
} else {
    Write-Output "Error: The path $targetPath was not found."
    Add-content -path $LogFilePath -value "Unable to find C:\Program Files (x86)\Intapp\Integration Builder path to copy over updated helper.bat on $(get-date)."
}




































# Check if the MSI installation was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "OpenJDK installation completed successfully."

    # Copy helper.bat to the target location, overwrite if it exists
    if (Test-Path -Path $helperSourcePath) {
        try {
            Copy-Item -Path $helperSourcePath -Destination $helperTargetPath -Force
            Write-Host "helper.bat successfully copied to $helperTargetPath."
        } catch {
            Write-Host "Error: Could not copy helper.bat. $_"
        }
    } else {
        Write-Host "Error: helper.bat file does not exist at $helperSourcePath."
    }
} else {
    Write-Host "Error: OpenJDK installation failed. Check the log at $logFilePath for details."
}
