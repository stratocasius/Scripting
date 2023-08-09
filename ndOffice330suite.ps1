### Creation of Scheduled Task
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File 'C:\jltools\ndOfficeSuite330\ndOfficeSuite330.ps1'"
$taskTrigger = New-ScheduledTaskTrigger -AtLogOff

Register-ScheduledTask -TaskName "InstallAppOnLogoff" -Action $taskAction -Trigger $taskTrigger -User "NT AUTHORITY\SYSTEM" -Force -Verbose 


#### Installer of MSI
# InstallApp.ps1

# Replace this section with the actual commands to install your Win32 app silently
# For example, if your installer is an .msi:
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i C:\path\to\YourAppInstaller.msi /quiet" -Wait

# Delete the scheduled task that runs this script on user logoff
Unregister-ScheduledTask -TaskName "InstallAppOnLogoff" -Confirm:$false




