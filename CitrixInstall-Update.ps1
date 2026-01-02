### Citrix Workspace 22.3.6002.6116 - 12/04/2024
# Removal of any 19.12 version of Citrix Workspace
& cmd /c "C:\ProgramData\Citrix\Citrix Workspace 1912\TrolleyExpress.exe /uninstall /silent"
# Install of Citrix Workspace 22.3.6002 using same 19.12 syntax - Logged at %LOCALAPPDATA\Temp\CTXReceiverInstallLogs-xxx 
& cmd /c CitrixWorkspaceApp.exe /noreboot /silent ALLOWSAVEPWD=A ALLOWADDSTORE=A /includeSSON /ENABLE_SSON=Yes /AutoUpdateCheck=disabled EnableCEIP=false STORE0="XenDesktop;https://citrix.jacksonlewis.com/Citrix/XenDesktop/discovery;On;Citrix XenDesktop Store" > C:\Programdata\Microsoft\IntuneManagementExtension\Logs\CitrixWS22.03.6002-INSTALL.log