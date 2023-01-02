### Litera Updated Suite Installer with Files - Updated .mdtx 11/24/2022
### Litera Compare - DocXTools - DocXTools Companion
### Removed Litera Metadact from Suite and now is provided as a standalone app.
### Temporarily exclude Rundll32.exe process from AV protection
### Updated Microsystems.Data.Enterprise.mdxt(11/23/22) for each C:\Users\username\Appdata\Local\Microsystems\Modules excluding Public
### Removes Litera Icons from users Desktop
### Rundll32.exe process AV exclusion
Add-MpPreference -ExclusionProcess rundll32.exe -Verbose
### Litera Installers
$LiteraCompare = "LiteraCompare_11.2.msi"
$LiteraCompareARGs = "/I $LiteraCompare WORDADDIN=1 OUTLOOKADDIN=1 EXCELADDIN=1 PPTADDIN=1 OCRMODULE=1 LICENSEKEY=CD-300Iw2l-ST0-X-QD65F /norestart ACCEPT_EULA_AND_TPLA=1 /qn /l C:\Windows\Temp\LiteraCompare11.2-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraCompareARGs -wait -nonewwindow
$LiteraDocXTools = "LiteraDocXtools11.14_x64.msi"
$LiteraDocXToolsARGs = "/I $LiteraDocXTools PRODUCT_KEY=DX-300Iw2l-ST0-1LLMMM-Q2974 ADMINISTRATOR=0 Role=DocXtools ACCEPT_EULA_AND_TPLA=1 AUTO_DELETE_STORE=true /qn /l C:\Windows\Temp\DocXTools11.14-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraDocXToolsARGs -wait -nonewwindow
$LiteraDocXToolsComp = "LiteraDocXtoolsCompanion_11.14.0_x64.msi"
$LiteraDocXToolsCompARGs = "/I $LiteraDocXToolsComp PRODUCT_KEY=DC-300Iw2l-ST0-X-QD75F ACCEPT_EULA_AND_TPLA=1 RIBBON_OPTION=LiteraTab.xml GUIDED=0 /qn /l C:\Windows\Temp\LiteraDocXCompanion-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraDocXToolsCompARGs -wait -nonewwindow
### Litera Customizations to C:\ProgramData\Litera folder
Copy-Item -path ".\LiteraCustomizations\Litera" -Destination "C:\ProgramData\" -recurse -force -Verbose
### Litera Microsystems.Data.Enterprise.mdxt to C:\Program Files\Microsystems\Modules folder
Copy-Item -path .\LiteraCustomizations\Microsystems.Data.Enterprise.mdxt -Destination "C:\Program Files\Microsystems\Modules\" -force -verbose
### Litera Microsystems.Data.Enterprise.mdxt to each User\Appdata\Microsystems\Modules folder
$Source = '.\LiteraCustomizations\Microsystems.Data.Enterprise.mdxt'
$listOfNames = Get-ChildItem C:\Users -Exclude Public |Select-Object -ExpandProperty Name 
foreach ($User in $listOfNames)
{
    New-Item -ItemType Directory -Path C:\Users\$User\appdata\Local\Microsystems\Modules -Force -Verbose
    Copy-Item -Path $Source -Destination C:\Users\$User\appdata\Local\Microsystems\Modules -Force -Verbose
}
### Remove exclusion from C:\Windows\System32\rundll32.exe from AV
Remove-MpPreference -ExclusionProcess rundll32.exe -Verbose
### Remove Litera icons from users desktop
Remove-Item -Path "C:\users\Public\Desktop\Litera*.lnk" -Recurse -Force -Verbose

