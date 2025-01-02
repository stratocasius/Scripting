### Create log/path
$logFilePath = "C:\Windows\Temp\NetdocsHKCUSettings-Autopilot-INSTALL.log"
###Set Item Properties to expected values### 
Set-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "useMapi" -Type String -value "true" 
Set-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "LoginRepoID" -Type String -value "CA-2V8C78SD" 
Set-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "UseEmbeddedNetWebBrowser" -Type String -value "true"
$logMessage = "ndOffice Current User settings were applied at HKCU:\Software\Netvoyage\NetDocuments on $(Get-Date) and consisted of:`nuseMapi - true`nLoginRepoID - CA-2V8C78SD`nUseEmbeddedNetWebBrowser - true"
###Detection:
###Creates path and string for detection 
New-Item -Path "HKCU:\Software\" -Name "Intune" -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Intune" -Name "Remediation_ndOfficeHKCUsettings" -Type String -Value 03282024 -ErrorAction SilentlyContinue
$logMessage | Out-File -FilePath $logFilePath -Append