### Uninstall Script for Litera Best Authority 6.15.0.14 - 12/31/2024
### Establish Litera Best Authority 6.15.0.14 removal transcript
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\LiteraBestAuthority6.15.0.14-Removal.log"

### Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\LiteraBestAuthority6.15.0.14-Removal.log"

# Define the uninstall command and log file
$uninstallCommand = "MsiExec.exe /X{B83EAE4A-7014-400D-9646-FC82FDE68DDD} /qn FULLUNINSTALL=1 /norestart"

### Adding LevitJames.Register.exe to AV process exclusion
Write-Output "Adding LevitJames.Register.exe to antivirus exclusion list..."
Add-MpPreference -ExclusionProcess LevitJames.Register.exe
Write-Output "LevitJames.Register.exe added to antivirus exclusion list."

# Start the command in cmd shell
Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCommand" -NoNewWindow -Wait

### Remove AV exclusion 
### Log message before removing LevitJames.Register.exe to AV process exclusion
Write-Output "Removing LevitJames.Register.exe to antivirus exclusion list..."
Remove-MpPreference -ExclusionProcess LevitJames.Register.exe
Write-Output "LevitJames.Register.exe removed from antivirus exclusion list."

### Stop transcript
Stop-Transcript