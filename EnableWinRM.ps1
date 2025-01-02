### Enable WinRM 
Enable-PSRemoting -Force
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true


Enter-PSSession -ComputerName localhost -Authentication Negotiate -Credential $cred