### Imports custom .xml of start-taskbar layouts.
Import-StartLayout -LayoutPath startmenu-taskbar.xml -MountPath C:\

###Creates path and string for detection
New-Item -Path "HKLM:\Software\" -Name "Intune" -Verbose
New-ItemProperty -Path "HKLM:\Software\Intune" -Name "Remediation_StartMenuTaskbar" -Type String -Value 07162021
Set-ItemProperty -Path "HKLM:\Software\Intune" -Name "Remediation_StartMenuTaskbar" -Value 07162021