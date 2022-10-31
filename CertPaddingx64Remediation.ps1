New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\' -Verbose
New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config' -Verbose
New-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config' -Name 'EnableCertPaddingCheck' -Value "1" -PropertyType DWord -ErrorAction SilentlyContinue