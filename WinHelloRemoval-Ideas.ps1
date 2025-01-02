Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name "AllowDomainPINLogon" -Value 0
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions -Name "value" -Value 0


Start-Process cmd -ArgumentList '/s,/c,takeown /f C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\NGC /r /d y & icacls 
C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\NGC /grant administrators:F /t & RD /S /Q 
C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc & MD 
C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc & icacls 
C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc /T /Q /C /RESET' -Verb runAs





## Other idea?
###### Remove Windows Hello biometric data
$removeBioData = Get-WmiObject -Namespace root\CIMv2\Security\MicrosoftTpm -Class Win32_Tpm

if ($removeBioData) {
    $removeBioData.SetPhysicalPresenceRequest(12)
} else {
    Write-Host "Windows Hello biometric data not found or unable to access TPM."
}
