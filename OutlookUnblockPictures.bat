@ECHO OFF 
REG ADD HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\office\16.0\outlook\options\Mail /f /v blockextcontent /t REG_DWORD /d "0"
REG ADD HKEY_CURRENT_USER\Software\Intune /f /v Remediation_UnblockOutlookPictures /t REG_SZ /d "09132022"