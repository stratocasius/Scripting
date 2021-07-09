###Remediation Browser HKCU Script###

###Skip error messages to continue script###
$ErrorActionPreference = "SilentlyContinue"


###What values$values are considered compliant###
$expectedValues = @()
$expectedValues += "2"
$expectedValues += "2"
$expectedValues += "2"
$expectedValues += "2"
$expectedValues += "2"
$expectedValues += "2"
$expectedValues += "2"
$expectedValues += "2"
$expectedValues += "2"
$expectedValues += "2"
$expectedValues += "2"
$expectedValues += "2"
$expectedValues += "2"

    
    ###What Results we actually get###
        $values = @()
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ADP.com" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\jacksonlewis.com" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ontrackinview.com" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\paypal.com" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\uscourts.gov" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\welcomeclient.com" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\Micronapps.com" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\securityeducation.com" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bna.com" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bloomberglaw.com" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" -Name "*"
        $values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\krollontrack.com" -Name "*"

        
    ###Keys we're modifying###
    $keyPaths = @()
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ADP.com"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\jacksonlewis.com"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ontrackinview.com"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\paypal.com"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\uscourts.gov"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\welcomeclient.com"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\Micronapps.com"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\securityeducation.com"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bna.com"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bloomberglaw.com"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com"
    $keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\krollontrack.com"

    ###Properties we're modifying###
        $properties = @()
        $properties += "*"
        $properties += "*"
        $properties += "*"
        $properties += "*"
        $properties += "*"
        $properties += "*"
        $properties += "*"
        $properties += "*"
        $properties += "*"
        $properties += "*"
        $properties += "*"
        $properties += "*"
        $properties += "*"
       

   ###Checking that all keys exist###
   $keyStatus = @()
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ADP.com" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\jacksonlewis.com" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ontrackinview.com" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\paypal.com" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\uscourts.gov" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\welcomeclient.com" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\Micronapps.com" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\securityeducation.com" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "KCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bna.com" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bloomberglaw.com" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\krollontrack.com" -ne $true){$false}

      ###Property existence check###
      $existenceCheck1 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ADP.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck2 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\jacksonlewis.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck3 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ontrackinview.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck4 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\paypal.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck5 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\uscourts.gov" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck6 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\welcomeclient.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck7 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck8 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\Micronapps.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck9 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\securityeducation.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck10 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bna.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck11 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bloomberglaw.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck12 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}
      $existenceCheck13 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\krollontrack.com" | Select-Object Property | Where-Object {@($_.Property) -contains '*'}

    ###Making an array for scalability###
    $existenceArray = 
        @(  @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ADP.com"; Value=If($null -ne $existenceCheck1){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\jacksonlewis.com"; Value=If($null -ne $existenceCheck2){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ontrackinview.com"; Value=If($null -ne $existenceCheck3){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\paypal.com"; Value=If($null -ne $existenceCheck4){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\uscourts.gov"; Value=If($null -ne $existenceCheck5){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\welcomeclient.com"; Value=If($null -ne $existenceCheck6){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com"; Value=If($null -ne $existenceCheck7){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\Micronapps.com"; Value=If($null -ne $existenceCheck8){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\securityeducation.com"; Value=If($null -ne $existenceCheck9){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bna.com"; Value=If($null -ne $existenceCheck10){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bloomberglaw.com"; Value=If($null -ne $existenceCheck11){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com"; Value=If($null -ne $existenceCheck12){'2'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\krollontrack.com"; Value=If($null -ne $existenceCheck13){'2'}})
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
        ($keyPaths.Length-10) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-11) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-12) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
        ($keyPaths.Length-13) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}})

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
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ADP.com" 
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ADP.com" -Name "*" -Type DWORD -Value 00000002 
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\jacksonlewis.com" 
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\jacksonlewis.com" -Name "*" -Type DWORD -Value 00000002
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ontrackinview.com"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ontrackinview.com" -Name "*" -Type DWORD -Value 00000002
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\paypal.com"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\paypal.com" -Name "*" -Type DWORD -Value 00000002
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\uscourts.gov"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\uscourts.gov" -Name "*" -Type DWORD -Value 00000002
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\welcomeclient.com"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\welcomeclient.com" -Name "*" -Type DWORD -Value 00000002
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" -Name "*" -Type DWORD -Value 00000002
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\Micronapps.com"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\Micronapps.com" -Name "*" -Type DWORD -Value 00000002
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\securityeducation.com" 
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\securityeducation.com" -Name "*" -Type DWORD -Value 00000002
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bna.com"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bna.com" -Name "*" -Type DWORD -Value 00000002
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bloomberglaw.com"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bloomberglaw.com" -Name "*" -Type DWORD -Value 00000002
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" 
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" -Name "*" -Type DWORD -value 00000002
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\krollontrack.com"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\krollontrack.com" -Name "*" -Type DWORD -value 00000002
        }  

            ###Set Item Properties to expected values###
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ADP.com" -Name "*" -Type DWORD -Value 00000002 
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\jacksonlewis.com" -Name "*" -Type DWORD -Value 00000002
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ontrackinview.com" -Name "*" -Type DWORD -Value 00000002
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\paypal.com" -Name "*" -Type DWORD -Value 00000002
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\uscourts.gov" -Name "*" -Type DWORD -Value 00000002
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\welcomeclient.com" -Name "*" -Type DWORD -Value 00000002
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" -Name "*" -Type DWORD -Value 00000002
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\Micronapps.com" -Name "*" -Type DWORD -Value 00000002
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\securityeducation.com" -Name "*" -Type DWORD -Value 00000002
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bna.com" -Name "*" -Type DWORD -Value 00000002
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bloomberglaw.com" -Name "*" -Type DWORD -Value 00000002
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" -Name "*" -Type DWORD -value 00000002
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\krollontrack.com" -Name "*" -Type DWORD -value 00000002

    elseif($incorrectValues -gt "0"){
        ###Set Item Properties to expected values###
            ###Set Item Properties to expected values###
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ADP.com" -Name "*" -Type DWORD -Value 00000002 
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\jacksonlewis.com" -Name "*" -Type DWORD -Value 00000002
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\ontrackinview.com" -Name "*" -Type DWORD -Value 00000002
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\paypal.com" -Name "*" -Type DWORD -Value 00000002
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\uscourts.gov" -Name "*" -Type DWORD -Value 00000002
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\welcomeclient.com" -Name "*" -Type DWORD -Value 00000002
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" -Name "*" -Type DWORD -Value 00000002
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\Micronapps.com" -Name "*" -Type DWORD -Value 00000002
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\securityeducation.com" -Name "*" -Type DWORD -Value 00000002
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bna.com" -Name "*" -Type DWORD -Value 00000002
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bloomberglaw.com" -Name "*" -Type DWORD -Value 00000002
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\netvoyage.com" -Name "*" -Type DWORD -value 00000002
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\krollontrack.com" -Name "*" -Type DWORD -value 00000002

}             

###Creates path and string for detection
New-Item -Path "HKCU:\Software\" -Name "Intune" -Verbose
New-ItemProperty -Path "HKCU:\Software\Intune" -Name "Remediation_TrustedSites" -Type String -Value 01222021











