###Remediation Script###

###Skip error messages to continue script###
$ErrorActionPreference = "SilentlyContinue"


###What values$values are considered compliant###
        $expectedValues = @()
        $expectedValues += "1"
        $expectedValues += "1"
        $expectedValues += "1"
        $expectedValues += "1"
        $expectedValues += "1"
        $expectedValues += "0"
        $expectedValues += "0"
        $expectedValues += "1"
        $expectedValues += "0"
        $expectedValues += "0"
        $expectedValues += "1"
        $expectedValues += "2800000000000000010000000000000000000000"
        $expectedValues += "1"
            
    ###What Results we actually get###
        $values = @()
        $values += Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RestrictNullSessAccess"
        $values += Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\LSA" -Name "RestrictAnonymous"
        $values += Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "RequireSecuritySignature"
        $values += Get-ItemPropertyValue -Path "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed2"
        $values += Get-ItemPropertyValue -Path "HKLM:\Software\Policies\Microsoft\Windows NT\SystemRestore" -Name "DisableSR"
        $values += Get-ItemPropertyValue -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services" -Name "fDenyTSConnections"
        $values += Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168" -Name "Enabled"
        $values += Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault"
        $values += Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled"
        $values += Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" -Name "DisableAddressSharing"
        $values += Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters\" -Name "EnableSecuritySignature"
        $values += Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -Name "WinHttpSettings"
        $values += Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown"
        
    ###Keys we're modifying###
        $keyPaths = @()
        $keyPaths += "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
        $keyPaths += "HKLM:\SYSTEM\CurrentControlSet\Control\LSA"
        $keyPaths += "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"
        $keyPaths += "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" 
        $keyPaths += "HKLM:\Software\Policies\Microsoft\Windows NT\SystemRestore" 
        $keyPaths += "HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services" 
        $keyPaths += "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168"
        $keyPaths += "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" 
        $keyPaths += "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" 
        $keyPaths += "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" 
        $keyPaths += "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" 
        $keyPaths += "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" 
        $keyPaths += "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" 
    ###Properties we're modifying###
        $properties = @()
        $properties += "RestrictNullSessAccess"
        $properties += "RestrictAnonymous"
        $properties += "RequireSecuritySignature"
        $properties += "RestartNotificationsAllowed2"
        $properties += "DisableSR"
        $properties += "fDenyTSConnections"
        $properties += "Enabled"
        $properties += "DisabledByDefault"
        $properties += "Enabled"
        $properties += "DisableAddressSharing"
        $properties += "EnableSecuritySignature"
        $properties += "WinHttpSettings" 
        $properties += "ClearPageFileAtShutdown"

    ###Checking that all keys exist###
        $keyStatus = @()
        $keyStatus += If(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\LSA" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\Software\Policies\Microsoft\Windows NT\SystemRestore" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -ne $true){$false}

    ###Property existence check###
    $existenceCheck1 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" | Select-Object Property | Where-Object {@($_.Property) -contains 'RestrictNullSessAccess'}
    $existenceCheck2 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\LSA" | Select-Object Property | Where-Object {@($_.Property) -contains 'RestrictAnonymous'}
    $existenceCheck3 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" | Select-Object Property | Where-Object {@($_.Property) -contains 'RequireSecuritySignature'}
    $existenceCheck4 = Get-Item -Path "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" | Select-Object Property | Where-Object {@($_.Property) -contains 'RestartNotificationsAllowed2'}
    $existenceCheck5 = Get-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\SystemRestore" | Select-Object Property | Where-Object {@($_.Property) -contains 'fDenyTSConnections'}
    $existenceCheck6 = Get-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services" | Select-Object Property | Where-Object {@($_.Property) -contains 'Enabled'}
    $existenceCheck7 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168" | Select-Object Property | Where-Object {@($_.Property) -contains 'DisabledByDefault'}
    $existenceCheck8 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" | Select-Object Property | Where-Object {@($_.Property) -contains 'Enabled'}
    $existenceCheck9 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" | Select-Object Property | Where-Object {@($_.Property) -contains 'DisableAddressSharing'}
    $existenceCheck10 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" | Select-Object Property | Where-Object {@($_.Property) -contains 'EnableSecuritySignature'}
    $existenceCheck11 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" | Select-Object Property | Where-Object {@($_.Property) -contains 'PromptForAutomaticUpdates'}
    $existenceCheck12 = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" | Select-Object Property | Where-Object {@($_.Property) -contains 'WinHttpSettings'}
    $existenceCheck13 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" | Select-Object Property | Where-Object {@($_.Property) -contains 'ClearPageFileAtShutdown'}

###Making an array for scalability###
    $existenceArray = 
        @(  @{Attribute="HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"; Value=If($null -ne $existenceCheck1){'RestrictNullSessAccess'}}
            @{Attribute="HKLM:\SYSTEM\CurrentControlSet\Control\LSA"; Value=If($null -ne $existenceCheck2){'RestrictAnonymous'}}
            @{Attribute="HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"; Value=If($null -ne $existenceCheck3){'RequireSecuritySignature'}}
            @{Attribute="HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings"; Value=If($null -ne $existenceCheck4){'RestartNotificationsAllowed2'}}
            @{Attribute="HKLM:\Software\Policies\Microsoft\Windows NT\SystemRestore"; Value=If($null -ne $existenceCheck5){'fDenyTSConnections'}}
            @{Attribute="HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services"; Value=If($null -ne $existenceCheck6){'Enabled'}}
            @{Attribute="HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168"; Value=If($null -ne $existenceCheck7){'DisabledByDefault'}}
            @{Attribute="HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server"; Value=If($null -ne $existenceCheck8){'Enabled'}}
            @{Attribute="HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server"; Value=If($null -ne $existenceCheck9){'DisableAddressSharing'}}
            @{Attribute="HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters"; Value=If($null -ne $existenceCheck10){'EnableSecuritySignature'}}
            @{Attribute="HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters"; Value=If($null -ne $existenceCheck11){'PromptForAutomaticUpdates'}}
            @{Attribute="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections"; Value=If($null -ne $existenceCheck12){'WinHttpSettings'}}
            @{Attribute="HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Value=If($null -ne $existenceCheck13){'ClearPageFileAtShutdown'}})

###Specifying what we want to read from###            
    $existence = $existenceArray.Value
        
###Putting everything together###
        $fullArray = @(
        ($keyPaths.Length-1) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-2) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-3) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-4) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-5) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-6) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-7) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-8) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-9) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-11) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-12) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-13) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-14) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}})

###Checking for key existence, return false if one is missing###
    $statusCheck = If($keyStatus.Count -gt "0"){
                $false
            }

    ###Checking property values, return false if any are incorrect###
        $valueCheck = foreach($object in $fullArray){
            If(@($object.Value) -ne @($object.ExpectedValue) -or 
               @($null -eq $object.Value)){
                $false
            }
        }

        $missingProperties = "$($properties.Count)" - "$($existence.Count)"
        $incorrectValues = $valueCheck.Count
        $missingKeys = $statusCheck.Count



    ###If either the existence check or value check contain a $false value, create all reg keys and properties###
        If($missingKeys -gt "0" -or $missingProperties -gt "0"){
            ###Create keys and properties##
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" 
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RestrictNullSessAccess" -Type DWORD -Value "1"
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\LSA" 
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\LSA" -Name "RestrictAnonymous" -Type DWORD -Value "1" 
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" 
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RequireSecuritySignature" -Type DWORD -Value "1" -Verbose
            New-Item -Path "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" 
            New-ItemProperty -Path "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed2" -Type DWORD -Value "1"
            New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\SystemRestore" 
            New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\SystemRestore" -Name "DisableSR " -Type DWORD -Value "1"
            New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services" 
            New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services" -Name "fDenyTSConnections" -Type DWORD -Value "0"
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168" 
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168" -Name "Enabled" -Type DWORD -Value "0"
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" 
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault" -Type DWORD -Value "1"
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" 
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Type DWORD -Value "0"
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" 
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" -Name "DisableAddressSharing" -Type DWORD -Value "0"
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" 
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "EnableSecuritySignature" -Type DWORD -Value "1"
            New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services" 
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -Name "WinHttpSettings" -Type BINARY -Value ([byte[]](0x28,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00))
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" 
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type DWORD -Value "0"

            ###Set Item Properties to expected values###
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RestrictNullSessAccess" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\LSA" -Name "RestrictAnonymous" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RequireSecuritySignature" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed2" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "DisableSR" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "fDenyTSConnections" -Type DWORD -Value "0"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168" -Name "Enabled" -Type DWORD -Value "0"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Type DWORD -Value "0"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" -Name "DisableAddressSharing" -Type DWORD -Value "0"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "EnableSecuritySignature" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -Name "WinHttpSettings" -Value ([byte[]](0x28,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00))
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type DWORD -Value "0"
            
        }elseif($incorrectValues -gt "0"){
            ###Set Item Properties to expected values###
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RestrictNullSessAccess" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\LSA" -Name "RestrictAnonymous" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RequireSecuritySignature" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed2" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "DisableSR" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "fDenyTSConnections" -Type DWORD -Value "0"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168" -Name "Enabled" -Type DWORD -Value "0"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Type DWORD -Value "0"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" -Name "DisableAddressSharing" -Type DWORD -Value "0"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "EnableSecuritySignature" -Type DWORD -Value "1"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -Name "WinHttpSettings" -Value ([byte[]](0x28,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00))
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type DWORD -Value "0"
        }

###Creates path and string for detection
New-Item -Path "HKLM:\Software\" -Name "Intune"
New-ItemProperty -Path "HKLM:\Software\Intune" -Name "Remediation_Security" -Type String -Value 01222021


