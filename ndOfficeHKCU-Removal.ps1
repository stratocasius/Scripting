### Create log/path
$logFilePath = "C:\Windows\Temp\NetdocsHKCUSettings-Autopilot-Removal.log"
###Set Item Properties to expected values### 
Remove-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments\" "useMapi" -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments\" "LoginRepoID" -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments\" "UseEmbeddedNetWebBrowser" -Force -ErrorAction SilentlyContinue
$logMessage = "ndOffice Current User settings were removed from HKCU:\Software\Netvoyage\NetDocuments on $(Get-Date) and consisted of:`nuseMapi - true`nLoginRepoID - CA-2V8C78SD`nUseEmbeddedNetWebBrowser - true"
$logMessage | Out-File -FilePath $logFilePath -Append