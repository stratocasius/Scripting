###Remediation Office HKCU Script###

###Skip error messages to continue script###
$ErrorActionPreference = "SilentlyContinue"

###What keyPaths$keyPaths are considered compliant###
$expectedValues = @()
$expectedValues += "C:\jltools\JLTemplates"
$expectedValues += "00000024"
$expectedValues += "250"
$expectedValues += "00000024"
$expectedValues += "1"
$expectedValues += "yXmy8s4dm7I="
$expectedValues += "iii/zuuLcVc="
$expectedValues += "1"
$expectedValues += "1"

###What Results we actually get###
$values = @()
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options" -Name "PersonalTemplates"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinAppt"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinBoxWidth"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinTasks"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\policies\microsoft\office\16.0\PowerPoint\Options" -Name "officestartdefaulttab"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "Hash" 
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name "Hash"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Graphics" -Name "DisableHardwareAcceleration"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General" -Name "DisableOutlookMobileHyperlink"


###Keys we're modifying###
$keyPaths = @()
$keyPaths += "HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options" 
$keyPaths += "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences"
$keyPaths += "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences"
$keyPaths += "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences"
$keyPaths += "HKCU:\Software\policies\microsoft\office\16.0\PowerPoint\Options"
$keyPaths += "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
$keyPaths += "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice"
$keyPaths += "HKCU:\Software\Microsoft\Office\16.0\Common\Graphics"
$keyPaths += "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General"

###Properties we're modifying###
    $properties = @()
    $properties += "PersonalTemplates"
    $properties += "PinAppt"
    $properties += "PinBoxWidth"
    $properties += "PinTasks"
    $properties += "officestartdefaulttab"
    $properties += "Hash"
    $properties += "Hash"
    $properties += "DisableHardwareAcceleration"
    $properties += "DisableOutlookMobileHyperlink"


   ###Checking that all keys exist###
   $keyStatus = @()
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\policies\microsoft\office\16.0\PowerPoint\Options" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Graphics" -ne $true){$false}

    ###Property existence check###
    $existenceCheck1 = Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options" | Select-Object Property | Where-Object {@($_.Property) -contains 'PersonalTemplates'}
    $existenceCheck2 = Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" | Select-Object Property | Where-Object {@($_.Property) -contains 'PinAppt'}
    $existenceCheck3 = Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" | Select-Object Property | Where-Object {@($_.Property) -contains 'PinBoxWidth'}
    $existenceCheck4 = Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" | Select-Object Property | Where-Object {@($_.Property) -contains 'PinTasks'}
    $existenceCheck5 = Get-Item -Path "HKCU:\Software\policies\microsoft\office\16.0\PowerPoint\Options" | Select-Object Property | Where-Object {@($_.Property) -contains 'officestartdefaulttab'}
    $existenceCheck6 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" | Select-Object Property | Where-Object {@($_.Property) -contains 'Hash'}
    $existenceCheck7 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" | Select-Object Property | Where-Object {@($_.Property) -contains 'Hash'}
    $existenceCheck8 = Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Graphics" | Select-Object Property | Where-Object {@($_.Property) -contains 'DisableHardwareAcceleration'}
    $existenceCheck9 = Get-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General" | Select-Object Property | Where-Object {@($_.Property) -contains 'DisableOutlookMobileHyperlink'}

    ###Making an array for scalability###
    $existenceArray = 
        @(  @{Attribute="HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options"; Value=If($null -ne $existenceCheck1){'PersonalTemplates'}}
            @{Attribute="HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences"; Value=If($null -ne $existenceCheck2){'PinAppt'}}
            @{Attribute="HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences"; Value=If($null -ne $existenceCheck3){'PinBoxWidth'}}
            @{Attribute="HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences"; Value=If($null -ne $existenceCheck4){'PinTasks'}}
            @{Attribute="HKCU:\Software\policies\microsoft\office\16.0\PowerPoint\Options"; Value=If($null -ne $existenceCheck5){'officestartdefaulttab'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"; Value=If($null -ne $existenceCheck6){'Hash'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice"; Value=If($null -ne $existenceCheck7){'Hash'}}
            @{Attribute="HKCU:\Software\Microsoft\Office\16.0\Common\Graphics"; Value=If($null -ne $existenceCheck8){'DisableHardwareAcceleration'}}
            @{Attribute="HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General"; Value=If($null -ne $existenceCheck9){'DisableOutlookMobileHyperlink'}})

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
            ($keyPaths.Length-9) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}})

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
    
           
            ## $incorrectValues = $valueCheck.Count
            $missingProperties = "$($properties.Count)" - "$($existence.Count)"
            $incorrectValues = $valueCheck.Count
            $missingKeys = $statusCheck.Count
        

    ###If either the existence check or value check contain a $false value, create all reg keys and properties###
    If($missingKeys -gt "0" -or $missingProperties -gt "0"){
        ###Create NetDocuments key and properties##
        New-Item -Path "HKCU:\Software\Microsoft\Office\16.0\PowerPoint" 
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options" -Name "PersonalTemplates" -Type String -Value "C:\jltools\JLTemplates" 
        New-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook" 
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinAppt" -Type DWORD -Value "00000024"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinBoxWidth" -Type DWORD -Value "250"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinAppt" -Type DWORD -Value "00000024"
        New-Item -Path "HKCU:\Software\policies\microsoft\office\16.0\PowerPoint\Options" 
        New-ItemProperty -Path "HKCU:\Software\policies\microsoft\office\16.0\PowerPoint\Options" -Name "officestartdefaulttab" -Type DWORD -value "1"
        New-Item -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http"
        New-Item -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "Hash" -Type String -value "yXmy8s4dm7I="
        New-Item -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https"
        New-Item -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" 
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name "Hash" -Type String -value "iii/zuuLcVc="
        New-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Graphics"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Graphics" -Name "DisableHardwareAcceleration" -Type DWORD -value "1"
        New-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General" -Name "DisableOutlookMobileHyperlink" -Type DWORD -value "1"

        }  

            ###Set Item Properties to expected values###
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options" -Name "PersonalTemplates" -Type String -Value "C:\jltools\JLTemplates"
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinAppt" -Type  DWORD -Value 00000024
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinBoxWidth" -Type DWORD -Value 250
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinTasks" -Type DWORD -Value 00000024
             Set-ItemProperty -Path "HKCU:\Software\policies\microsoft\office\16.0\PowerPoint\Options" -Name "officestartdefaulttab" -Type DWORD -Value 00000001
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "Hash" -Type String -Value "yXmy8s4dm7I="
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name "Hash" -Type String -Value "iii/zuuLcVc="
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Graphics" -Name "DisableHardwareAcceleration" -Type DWORD -Value 00000001
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General" -Name "DisableOutlookMobileHyperlink" -Type DWORD -Value 00000001
    
    elseif($incorrectValues -gt "0"){
        ###Set Item Properties to expected values###
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options" -Name "PersonalTemplates" -Type String -Value "C:\jltools\JLTemplates"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinAppt" -Type DWORD -Value 00000024
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinBoxWidth" -Type DWORD -Value 250
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" -Name "PinTasks" -Type DWORD -Value 00000024
        Set-ItemProperty -Path "HKCU:\Software\policies\microsoft\office\16.0\PowerPoint\Options" -Name "officestartdefaulttab" -Type DWORD -Value 00000001
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "Hash" -Type String -Value "yXmy8s4dm7I="
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name "Hash" -Type String -Value "iii/zuuLcVc="
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Graphics" -Name "DisableHardwareAcceleration" -Type DWORD -Value 00000001
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General" -Name "DisableOutlookMobileHyperlink" -Type DWORD -Value 00000001
}

###Creates path and string for detection
New-Item -Path "HKCU:\Software\" -Name "Intune" -Verbose
New-ItemProperty -Path "HKCU:\Software\Intune" -Name "Remediation_Office" -Type String -Value 01222021


