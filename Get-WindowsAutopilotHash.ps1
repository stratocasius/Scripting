New-Item -Type Directory -Path "C:\HWID"
Set-Location -Path "C:\HWID"
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Install-Script -Name Get-WindowsAutopilotInfo -Confirm
Get-WindowsAutopilotInfo -OutputFile AutopilotHWID.csv
Send-MailMessage -Attachments