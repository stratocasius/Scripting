### Litera DocXTools Companion Manual Installer 11.22.0.13
### Rundll32.exe process AV exclusion
Add-MpPreference -ExclusionProcess "C:\Windows\System32\rundll32.exe" -Force
$LiteraDocXToolsComp = "LiteraDocXtoolsCompanion_11.22.0_x64.msi"
$LiteraDocXToolsCompARGs = "/I $LiteraDocXToolsComp PRODUCT_KEY=DC-300Iw2l-ST0-X-QD75F ACCEPT_EULA_AND_TPLA=1 RIBBON_OPTION=LiteraTab.xml GUIDED=0 /qn /l C:\Windows\Temp\LiteraDocXCompanion11.22-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $LiteraDocXToolsCompARGs -wait -nonewwindow
### Remove exclusion from C:\Windows\System32\rundll32.exe from AV
Remove-MpPreference -ExclusionProcess "C:\Windows\System32\rundll32.exe" -Force