### Egress Mail Protection Install with registry edits
$EgressMSI = "egressemailprotection.msi"
$EgressARGs = "/I $EgressMSI /qn /l C:\Windows\Temp\EgressMailProtection-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $EgressARGs -wait -nonewwindow
### Egress Registry Edits
if((Test-Path -LiteralPath "HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Resiliency\AddinList") -ne $true) {  New-Item "HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Resiliency\AddinList" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\EgressEmailProtection") -ne $true) {  New-Item "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\EgressEmailProtection" -force -ea SilentlyContinue };
Remove-Item -LiteralPath "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\DisabledItems" -force;
if((Test-Path -LiteralPath "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\DisabledItems") -ne $true) {  New-Item "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\DisabledItems" -force -ea SilentlyContinue };
Remove-Item -LiteralPath "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\CrashingAddinList" -force;
if((Test-Path -LiteralPath "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\CrashingAddinList") -ne $true) {  New-Item "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\CrashingAddinList" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\DoNotDisableAddinList") -ne $true) {  New-Item "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\DoNotDisableAddinList" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\NotificationReminderAddinData") -ne $true) {  New-Item "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\NotificationReminderAddinData" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Egress\Switch") -ne $true) {  New-Item "HKLM:\SOFTWARE\Egress\Switch" -force -ea SilentlyContinue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Wow6432Node\Egress\Switch") -ne $true) {  New-Item "HKLM:\SOFTWARE\Wow6432Node\Egress\Switch" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Resiliency\AddinList' -Name 'EgressEmailProtection' -Value '1' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\EgressEmailProtection' -Name 'LoadBehavior' -Value 3 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\DoNotDisableAddinList' -Name 'EgressEmailProtection' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\NotificationReminderAddinData' -Name 'EgressEmailProtection\dtype' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Resiliency\NotificationReminderAddinData' -Name 'EgressEmailProtection' -Value -1770355635 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Egress\Switch' -Name 'MinimumSizeKB' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Egress\Switch' -Name 'ForceGatewayMode' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Egress\Switch' -Name 'GatewayAddress' -Value 'EgressGateway' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Egress\Switch' -Name 'Server' -Value 'us1.esi.egress.com' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Egress\Switch' -Name 'OutlookDisableCategories' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Egress\Switch' -Name 'OutlookSentPackagesButton' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Egress\Switch' -Name 'LargeFileMode' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Egress\Switch' -Name 'IdentityProviderHost' -Value 'wsfed://login.microsoftonline.com:443/6ab77482-4dda-43b3-9e50-82db3e426c2c/wsfed?sso-acs=https%3A%2F%2Fus1.esi.egress.com%2Fui%2F&sso-refresh=1' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Wow6432Node\Egress\Switch' -Name 'MinimumSizeKB' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Wow6432Node\Egress\Switch' -Name 'ForceGatewayMode' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Wow6432Node\Egress\Switch' -Name 'GatewayAddress' -Value 'EgressGateway' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Wow6432Node\Egress\Switch' -Name 'Server' -Value 'us1.esi.egress.com' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Wow6432Node\Egress\Switch' -Name 'OutlookDisableCategories' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Wow6432Node\Egress\Switch' -Name 'OutlookSentPackagesButton' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Wow6432Node\Egress\Switch' -Name 'LargeFileMode' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Wow6432Node\Egress\Switch' -Name 'IdentityProviderHost' -Value 'wsfed://login.microsoftonline.com:443/6ab77482-4dda-43b3-9e50-82db3e426c2c/wsfed?sso-acs=https%3A%2F%2Fus1.esi.egress.com%2Fui%2F&sso-refresh=1' -PropertyType String -Force -ea SilentlyContinue;