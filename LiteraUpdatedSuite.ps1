### Litera Updated Suite Installer with Files - 10/18/2022
### Removed Litera Metadact from Suite and now is provided as a standalone app.
### Exclude Rundll32.exe process from AV
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
### Litera Customizations
Copy-Item -path ".\LiteraCustomizations\Litera" -Destination "C:\ProgramData\Litera" -recurse -force -verbose
Remove-Item -path $Env:LOCALAPPDATA\Microsystems\Modules\Microsystems.Data.Enterprise.mdxt -force -verbose
Copy-Item -path "LiteraCustomizations\Microsystems.Data.Enterprise.mdxt" -Destination "C:\Program Files\Microsystems\Modules\" -force -verbose
### Remove exclusion from C:\Windows\System32\rundll32.exe from AV
Remove-MpPreference -ExclusionProcess rundll32.exe -Verbose