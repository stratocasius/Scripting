### ResearchMonitor Agent 9.5.1.5 Install
### Removal of existing RM Agent installs.
& cmd /c C:\Windows\System32\wbem\WMIC.exe product where "name like 'ResearchMonitor Agent%'" call uninstall > C:\Windows\Temp\ResearchMonitor-Agent-Removal.log
### ResearchMonitor Agent 9.5.1.5 Install
$RMAgentMSI = "RM_Agent_v9.5.1.5.msi"
$RMAgentARGs = "/I $RMAgentMSI AGENTSERVICEURI=https://qovxb.usage.trgscreen.com/rmagentservice AGENTSERVICEAPIKEY=FE476385-E85B-45BF-9DE9-C7D745BA9C91 /passive /norestart /l C:\Windows\Temp\ResearchMonitor950-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList RMAgentARGs -wait -nonewwindow