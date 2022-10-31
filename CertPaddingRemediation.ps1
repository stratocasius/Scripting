New-item -Path 'HKLM:\Software\Microsoft\Cryptography\Wintrust\' -Verbose
New-Item -Path 'HKLM:\Software\Microsoft\Cryptography\Wintrust\Config' -Verbose
New-ItemProperty -Path 'HKLM:\Software\Microsoft\Cryptography\Config' -Name 'EnableCertPaddingCheck' -Value "1" -PropertyType DWord -ErrorAction SilentlyContinue





