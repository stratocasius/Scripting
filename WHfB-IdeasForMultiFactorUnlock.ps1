Do it via proactive remediation. https://seesmitty.com/how-to-deploy-a-registry-key-using-proactive-remediation/

Detection script I used in testing.

#Try-Catch for error handling

Try {

# After you export the RegKey, be sure you copy/paste it HERE: https://reg2ps.azurewebsites.net/

# This will create the detection script and the remediation script.

if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork")){ Exit 1 };

`if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork' -Name 'DisablePostLogonProvisioning' -ea SilentlyContinue) -eq 1) {  } else { Exit 1 };`

`if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork' -Name 'Enabled' -ea SilentlyContinue) -eq 1) {  } else { Exit 1 };`
}Catch{

#captures and reports the exception errors of the script

Write-Host $_.Exception

Exit 2000

}

Remediation script I used in testing.

#Try-Catch for error handling

Try {

# After you export the RegKey, be sure you copy/paste it HERE: https://reg2ps.azurewebsites.net/

# This will create the detection script and the remediation script.

# Reg2CI (c) 2022 by Roger Zander

if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork") -ne $true) { New-Item "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork" -force -ea SilentlyContinue };

New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork' -Name 'DisablePostLogonProvisioning' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;

New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork' -Name 'Enabled' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;

}Catch{

#captures and reports the exception errors of the script

Write-Host $_.Exception

Exit 2000

}

Registry key

Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PassportForWork]

"DisablePostLogonProvisioning"=dword:00000001

"Enabled"=dword:00000001