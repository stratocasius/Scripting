# Define the file path to check
$filePathToCheck = "C:\Program Files\Common Files\microsoft shared\VSTO\10.0\VSTOinstaller.exe"
# Check if the file exists
if (-not (Test-Path -Path $filePathToCheck)) {
    # Define the script to run if the file doesn't exist
    $scriptToRun = {
        # Define the registry path and values
        $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"
        $valueName = "DisablePatch"
        $vstorCommand = "vstor_redist.exe"
        $vstorCommandArgs = " /q /norestart"
        # Set the DisablePatch value to 0
        Set-ItemProperty -Path $registryPath -Name $valueName -Value 0 -Type DWord -Verbose
        # Run the command in system context
& cmd /c "$vstorCommand $vstorCommandArgs" -Wait -NoNewWindow
    }
    # Run the script
    Invoke-Command -ScriptBlock $scriptToRun
    # Set the DisablePatch value back to 1
    Set-ItemProperty -Path $registryPath -Name $valueName -Value 1 -Type DWord -Verbose
    $today = Get-Date
    Out-File -FilePath C:\Windows\Temp\VSTOR2010-INSTALL.log -Append
    Set-Content -path C:\Windows\Temp\VSTOR2010-INSTALL.log -Value "VSTO 2010 10.0.60915 was installed on $Today" -Force
}
else
{
    $today = Get-Date
    Out-File -FilePath C:\Windows\Temp\VSTOR2010-Installed.log -Append
    Set-Content -path C:\Windows\Temp\VSTOR2010-Installed.log -Value "VSTO 2010 was found at C:\Program Files\Common Files\microsoft shared\VSTO\10.0\VSTOinstaller.exe on $Today" -Force
}