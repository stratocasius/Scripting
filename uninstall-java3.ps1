
#Find all Java products excluding the auto updater which actually gets uninstalled when the main install is removed.
[array]$javas=Get-WmiObject -query "select * from win32_Product where (Name like 'Java %' or Name like 'Java(TM)%' or Name like 'Java(TM) 6%' or Name like 'JavaFX%') and Name <> 'Java Auto Updater'"
if ($javas.count -gt 0)
{
    write-host "Java is already Installed" -ForegroundColor Yellow
    
    #Get all the Java processes and kill them. If java is running and the processes aren't killed then this script will invoke a sudden reboot.
    [array]$processes=Get-Process -Name "Java*"
    if ($processes.Count -gt 0){foreach ($myprocess in $processes){$myprocess.kill()}}
    
    #Loop through the installed Java products.
    foreach($java in $javas){
        
        write-host "Uninstalling "$java.name -ForegroundColor Yellow
        $java.Uninstall()
              
    
    }
}