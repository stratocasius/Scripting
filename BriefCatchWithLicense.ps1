### BriefCatch 2.2.112 Installer, Cert and License File - 12/08/2022
### Rundll32.exe process AV exclusion
Add-MpPreference -ExclusionProcess rundll32.exe -Verbose
### BriefCatch Certificate file.
Copy-Item -Path .\lwp.cer -Destination C:\Windows\Temp -Force -Verbose -ErrorAction SilentlyContinue
### BriefCatch Installer
$BriefCatch="BCMSSetupLM.msi"
$BriefCatchARGs="/I $BriefCatch LICENSESOURCE=C:\Windows\Temp\lwp.cer /qn /l C:\Windows\Temp\BriefCatch2.2.112-INSTALL.log" 
Start-Process "msiexec.exe" -ArgumentList $BriefCatchARGs -wait -nonewwindow
### BriefCatch License file.
$Source = 'BriefCatch_license.key'
$listOfNames = Get-ChildItem C:\Users -Exclude Public |Select-Object -ExpandProperty Name 
foreach ($User in $listOfNames)
{
    New-Item -ItemType Directory -Path C:\Users\$User\AppData\Roaming\bcms -Force -Verbose -ErrorAction SilentlyContinue
    Copy-Item -Path $Source -Destination C:\Users\$User\AppData\Roaming\bcms -Force -Verbose -ErrorAction SilentlyContinue
    }
### Remove exclusion from C:\Windows\System32\rundll32.exe from AV
Remove-MpPreference -ExclusionProcess rundll32.exe -Verbose






