### Litera Compare 11.8 Updated .mdtx 07/17/2023
### Temporarily exclude Rundll32.exe process from AV protection
### Updated Microsystems.Data.Enterprise.mdxt(07/17/2023) for C:\ProgramData\Litera each C:\Users\username\Appdata\Local\Microsystems\Modules excluding Public
### Stop Compare service
Stop-Process -Name lcp_clip -Force -ErrorAction SilentlyContinue
### Rundll32.exe process AV exclusion
Add-MpPreference -ExclusionProcess rundll32.exe
### Litera Installers
$LiteraCompare = "LiteraCompare_11.8.msi"
$LiteraCompareARGs = "/I $LiteraCompare WORDADDIN=1 OUTLOOKADDIN=1 EXCELADDIN=1 PPTADDIN=1 OCRMODULE=1 LICENSEKEY=CD-300Iw2l-ST0-X-QD65F /norestart ACCEPT_EULA_AND_TPLA=1 /qn /l C:\Windows\Temp\LiteraCompare11.8-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraCompareARGs -wait -nonewwindow
### Litera Customizations to C:\ProgramData\Litera folder
Copy-Item -path ".\Litera" -Destination "C:\ProgramData\" -recurse -Force
### Litera Microsystems.Data.Enterprise.mdxt to C:\Program Files\Microsystems\Modules folder
Copy-Item -path "Microsystems.Data.Enterprise.mdxt" -Destination "C:\Program Files\Microsystems\Modules\" -force
### Copies .mdxt to each users %LOCALAPPDATA%\Microsystems\Modules folder
$Source = 'Microsystems.Data.Enterprise.mdxt'
$listOfNames = Get-ChildItem C:\Users -Exclude Public |Select-Object -ExpandProperty Name
foreach ($User in $listOfNames)
{
    New-Item -ItemType Directory -Path C:\Users\$User\appdata\Local\Microsystems\Modules -Force
    Copy-Item -Path $Source -Destination C:\Users\$User\appdata\Local\Microsystems\Modules -Force
}
### Remove exclusion from C:\Windows\System32\rundll32.exe from AV
Remove-MpPreference -ExclusionProcess rundll32.exe -Force
### Remove Litera icons from users desktop
Remove-Item -Path "C:\users\Public\Desktop\Litera*.lnk" -Recurse -Force