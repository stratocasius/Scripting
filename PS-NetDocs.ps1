$java = Get-WmiObject -Class win32reg_AddRemovePrograms | where { $_.DisplayName -like "*Netdocuments*"}
 $msiexec = "C:\Windows\system32\msiexec.exe";
 $msiexecargs = '/x "$($app.IdentifyingNumber)" /qn /norestart'
 
if ($java -ne $null)
 {
     foreach ($app in $java)
     {
         write-host $app.LocalPackage
         write-host $app.IdentifyingNumber
         &C:\Windows\system32\cmd.exe /c "C:\Windows\system32\msiexec.exe /x $($app.IdentifyingNumber) /qn"
         Start-Process -FilePath $msiexec -Arg $msiexecargs -Wait -Passthru
         [Diagnostics.Process]::Start($msiexec, $msiexecargs);
     }
 }
 if ($java -ne $null)
 {
     foreach ($app in $java)
     {
         write-host $app.LocalPackage
         write-host $app.IdentifyingNumber
         &C:\Windows\system32\cmd.exe /c "C:\Windows\system32\msiexec.exe /x $($app.IdentifyingNumber) /qn"
         Start-Process -FilePath $msiexec -Arg $msiexecargs -Wait -Passthru
         [Diagnostics.Process]::Start($msiexec, $msiexecargs);
     }
 }
 else { exit }