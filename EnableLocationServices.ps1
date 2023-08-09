# Set the registry key value to enable Location Services
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value 1
# Restart the Windows Location Service
Restart-Service -Name "lfsvc"