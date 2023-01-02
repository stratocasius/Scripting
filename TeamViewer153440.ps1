### TeamViewer 15.34.4.0 Install (with removal)
### Removal of TeamViewer
cmd /c WMIC.exe product where "name like 'TeamViewer%'" call uninstall > C:\Windows\Temp\TeamViewer-Removal.log
### TeamViewer 15.34.4.0 Installer
$TeamViewer="TeamViewer_Host.msi"
$TeamViewerARGs="/I $ndOffice /qn CUSTOMCONFIGID=6gt8mb3 APITOKEN=16621801-TN3BCQXdDOAjbSLrq3C0 ASSIGNMENTOPTIONS="--grant-easy-access --reassign --group-id g245550865" /norestart /l C:\Windows\Temp\TeamViewer15.34.4.0-INSTALL.log
Start-Process "msiexec.exe" -ArgumentList $TeamViewerARGs -wait -nonewwindow