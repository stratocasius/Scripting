@ECHO OFF 
REG ADD HKEY_LOCAL_MACHINE\Software\Microsoft\Cryptography\Wintrust\Config /f /v EnableCertPaddingCheck /t REG_DWORD /d "1"
REG ADD HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config /f /v EnableCertPaddingCheck /t REG_DWORD /d "1"
REG ADD HKEY_LOCAL_MACHINE\Software\Intune /v Remediation_CertPaddingCheck /t REG_SZ /d "09132022"