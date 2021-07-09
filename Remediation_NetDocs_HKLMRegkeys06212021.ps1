###Remediation Script###

###Skip error messages to continue script###
$ErrorActionPreference = "SilentlyContinue"


###What values$values are considered compliant###
        $expectedValues = @()
        $expectedValues += "None"
        $expectedValues += "True"
        $expectedValues += "False"
        $expectedValues += "False"
        $expectedValues += "True"
        $expectedValues += "LastPage"
        $expectedValues += "False"
        $expectedValues += "False"
        $expectedValues += "False"
        $expectedValues += "False"
        $expectedValues += "True"
        $expectedValues += "True"
    
    ###What Results we actually get###
        $values = @()
        $values += Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\NetDocuments" -Name "OfflineModeNotification " #None
        $values += Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\NetDocuments\ndMail" -Name "RankingBarEnabled" #True
        $values += Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\NetDocuments\ndMail" -Name "ShowSuccessfulToastNotification" #False
        $values += Get-ItemPropertyValue -Path "HKLM:\Software\NetDocuments\ndMail" -Name "ShowOutlookPanels" #False
        $values += Get-ItemPropertyValue -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "DontShowStampConflictDialog" #True
        $values += Get-ItemPropertyValue -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "StampingLocation" #LastPage
        $values += Get-ItemPropertyValue -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "AutoUpdateEnabled" #False
        $values += Get-ItemPropertyValue -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "PromptFileEmails" #False
        $values += Get-ItemPropertyValue -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "ShowExtOutlookFeatures" #False
        $values += Get-ItemPropertyValue -Path "HKLM:\Software\NetVoyage\NetDocuments\ndSync" -Name "PromptForAutomaticUpdates" #False
        $values += Get-ItemPropertyValue -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "UseEmbeddedNetWebBrowser" #False
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "UseEmbeddedNetWebBrowser" #False

    ###Keys we're modifying###
        $keyPaths = @()
        $keyPaths += "HKLM:\SOFTWARE\NetDocuments"
        $keyPaths += "HKLM:\SOFTWARE\NetDocuments\ndMail" 
        $keyPaths += "HKLM:\SOFTWARE\NetDocuments\ndMail" 
        $keyPaths += "HKLM:\Software\NetDocuments\ndMail" 
        $keyPaths += "HKLM:\Software\NetVoyage\NetDocuments" 
        $keyPaths += "HKLM:\Software\NetVoyage\NetDocuments" 
        $keyPaths += "HKLM:\Software\NetVoyage\NetDocuments"
        $keyPaths += "HKLM:\Software\NetVoyage\NetDocuments" 
        $keyPaths += "HKLM:\Software\NetVoyage\NetDocuments" 
        $keyPaths += "HKLM:\Software\NetVoyage\NetDocuments\ndSync" 
        $keyPaths += "HKLM:\Software\NetVoyage\NetDocuments"
        $keyPaths += "HKCU:\Software\NetVoyage\NetDocuments"

    ###Properties we're modifying###
        $properties = @()
        $properties += "OfflineModeNotification " #None
        $properties += "RankingBarEnabled" #True
        $properties += "ShowSuccessfulToastNotification" #False
        $properties += "ShowOutlookPanels" #False
        $properties += "DontShowStampConflictDialog" #True
        $properties += "StampingLocation" #LastPage
        $properties += "AutoUpdateEnabled" #False
        $properties += "PromptFileEmails" #False
        $properties += "ShowExtOutlookFeatures" #False
        $properties += "PromptForAutomaticUpdates" #False 
        $properties += "UseEmbeddedNetWebBrowser" #True 

    ###Checking that all keys exist###
        $keyStatus = @()
        $keyStatus += If(Test-Path -Path "HKLM:\SOFTWARE\NetDocuments\ndMail" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\SOFTWARE\NetDocuments" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\Software\NetVoyage\NetDocuments" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKLM:\Software\NetVoyage\NetDocuments\ndSync" -ne $true){$false}
        $keyStatus += If(Test-Path -Path "HKCU:\SOFTWARE\NetVoyage\NetDocuments" -ne $true){$false}

    ###Property existence check###
    $existenceCheck1 = Get-Item -Path "HKLM:\SOFTWARE\NetDocuments" | Select-Object Property | Where-Object {@($_.Property) -contains 'OfflineModeNotification '}
    $existenceCheck2 = Get-Item -Path "HKLM:\SOFTWARE\NetDocuments\ndMail" | Select-Object Property | Where-Object {@($_.Property) -contains 'RankingBarEnabled'}
    $existenceCheck3 = Get-Item -Path "HKLM:\SOFTWARE\NetDocuments\ndMail" | Select-Object Property | Where-Object {@($_.Property) -contains 'ShowSuccessfulToastNotification'}
    $existenceCheck4 = Get-Item -Path "HKLM:\SOFTWARE\NetDocuments\ndMail" | Select-Object Property | Where-Object {@($_.Property) -contains 'ShowOutlookPanels'}
    $existenceCheck5 = Get-Item -Path "HKLM:\Software\NetVoyage\NetDocuments" | Select-Object Property | Where-Object {@($_.Property) -contains 'DontShowStampConflictDialog'}
    $existenceCheck6 = Get-Item -Path "HKLM:\Software\NetVoyage\NetDocuments" | Select-Object Property | Where-Object {@($_.Property) -contains 'StampingLocation'}
    $existenceCheck7 = Get-Item -Path "HKLM:\Software\NetVoyage\NetDocuments" | Select-Object Property | Where-Object {@($_.Property) -contains 'AutoUpdateEnabled'}
    $existenceCheck8 = Get-Item -Path "HKLM:\Software\NetVoyage\NetDocuments" | Select-Object Property | Where-Object {@($_.Property) -contains 'PromptFileEmails'}
    $existenceCheck9 = Get-Item -Path "HKLM:\Software\NetVoyage\NetDocuments" | Select-Object Property | Where-Object {@($_.Property) -contains 'ShowExtOutlookFeatures'}
    $existenceCheck10 = Get-Item -Path "HKLM:\Software\NetVoyage\NetDocuments\ndSync" | Select-Object Property | Where-Object {@($_.Property) -contains 'PromptForAutomaticUpdates'}
    $existenceCheck11 = Get-Item -Path "HKLM:\Software\NetVoyage\NetDocuments\" | Select-Object Property | Where-Object {@($_.Property) -contains 'UseEmbeddedNetWebBrowser'}
    $existenceCheck12 = Get-Item -Path "HKCU:\Software\NetVoyage\NetDocuments\" | Select-Object Property | Where-Object {@($_.Property) -contains 'UseEmbeddedNetWebBrowser'}

###Making an array for scalability###
    $existenceArray = 
        @(  @{Attribute="HKLM:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck1){'OfflineModeNotification'}}
            @{Attribute="HKLM:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck2){'RankingBarEnabled'}}
            @{Attribute="HKLM:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck3){'ShowSuccessfulToastNotification'}}
            @{Attribute="HKLM:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck4){'ShowOutlookPanels'}}
            @{Attribute="HKLM:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck5){'DontShowStampConflictDialog'}}
            @{Attribute="HKLM:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck6){'StampingLocation'}}
            @{Attribute="HKLM:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck7){'AutoUpdateEnabled'}}
            @{Attribute="HKLM:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck8){'PromptFileEmails'}}
            @{Attribute="HKLM:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck9){'ShowExtOutlookFeatures'}}
            @{Attribute="HKLM:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck10){'PromptForAutomaticUpdates'}})
            @{Attribute="HKLM:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck10){'UseEmbeddedNetWebBrowser'}})
            @{Attribute="HKCU:\SOFTWARE\NetDocuments"; Value=If($null -ne $existenceCheck10){'UseEmbeddedNetWebBrowser'}})

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
        ($keyPaths.Length-10) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}})
        ($keyPaths.Length-11) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}})
        ($keyPaths.Length-12) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}})

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
            ###Create NetDocuments keys and properties##
            New-Item -Path "HKLM:\SOFTWARE\" -Name "NetDocuments" 
            New-ItemProperty -Path "HKLM:\SOFTWARE\NetDocuments" -Name "OfflineModeNotification " -Value "None"
            New-ItemProperty -Path "HKLM:\SOFTWARE\NetDocuments" -Name "UseEmbeddedNetWebBrowser" -Value "True"
            New-ItemProperty -Path "HKCU:\SOFTWARE\NetDocuments" -Name "UseEmbeddedNetWebBrowser" -Value "True"

            ###Create ndMail key and properties###
            New-Item -Path "HKLM:\Software\NetDocuments\" -Name "ndMail" 
            New-ItemProperty -Path "HKLM:\Software\NetDocuments\ndMail" -Name "ShowOutlookPanels" -Value "False" 
            New-ItemProperty -Path "HKLM:\Software\NetDocuments\ndMail" -Name "ShowSuccessfulToastNotification" -Value "False" 
            New-ItemProperty -Path "HKLM:\Software\NetDocuments\ndMail" -Name "RankingBarEnabled" -Value "True"
            
            ###Create NetVoyage\NetDocuments keys and properties###
            New-Item -Path "HKLM:\Software\" -Name "NetVoyage" 
            New-Item -Path "HKLM:\Software\NetVoyage" -Name "NetDocuments"  
            New-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "DontShowStampConflictDialog" -Value "True" 
            New-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "StampingLocation" -Value "LastPage" 
            New-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "AutoUpdateEnabled" -Value "False" 
            New-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "PromptFileEmails" -Value "False"  
            New-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "ShowExtOutlookFeatures" -Value "False"

            ###Create ndSync key and properties###
            New-Item -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "ndSync" 
            New-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments\ndSync" -Name "PromptForAutomaticUpdates" -Value "False"

            ###Set Item Properties to expected values###
            Set-ItemProperty -Path "HKLM:\SOFTWARE\NetDocuments\ndMail" -Name "RankingBarEnabled" -Value "True"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\NetDocuments\ndMail" -Name "ShowSuccessfulToastNotification" -Value "False"
            Set-ItemProperty -Path "HKLM:\Software\NetDocuments\ndMail" -Name "ShowOutlookPanels" -Value "False"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\NetDocuments" -Name "OfflineModeNotification" -Value "None"
            Set-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "DontShowStampConflictDialog" -Value "True"
            Set-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "StampingLocation" -Value "LastPage"
            Set-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "AutoUpdateEnabled" -Value "False"
            Set-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments\ndSync" -Name "PromptForAutomaticUpdates" -Value "False"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\NetVoyage\NetDocuments" -Name "UseEmbeddedNetWebBrowser" -Value "True"
            Set-ItemProperty -Path "HKCU:\SOFTWARE\NetVoyage\NetDocuments" -Name "UseEmbeddedNetWebBrowser" -Value "True"
            
            
        }elseif($incorrectValues -gt "0"){
            ###Set Item Properties to expected values###
            Set-ItemProperty -Path "HKLM:\SOFTWARE\NetDocuments\ndMail" -Name "RankingBarEnabled" -Value "True"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\NetDocuments\ndMail" -Name "ShowSuccessfulToastNotification" -Value "False"
            Set-ItemProperty -Path "HKLM:\Software\NetDocuments\ndMail" -Name "ShowOutlookPanels" -Value "False"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\NetDocuments" -Name "OfflineModeNotification " -Value "None"
            Set-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "DontShowStampConflictDialog" -Value "True"
            Set-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "StampingLocation" -Value "LastPage"
            Set-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "AutoUpdateEnabled" -Value "False"
            Set-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments\ndSync" -Name "PromptForAutomaticUpdates" -Value "False"
            Set-ItemProperty -Path "HKLM:\Software\NetVoyage\NetDocuments" -Name "UseEmbeddedNetWebBrowser" -Value "True"
            Set-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "UseEmbeddedNetWebBrowser" -Value "True"
        }
###Creates path and string for detection
New-Item -Path "HKLM:\Software\" -Name "Intune" -Verbose
New-ItemProperty -Path "HKLM:\Software\Intune" -Name "Remediation_NetDocs" -Type String -Value 06212021