###Remediation Windows Fonts Script###
### Copies both Sabon and Frangid font files to C:\Windows\Fonts
Copy-Item -Path .\*.TTF -Destination "C:\Windows\Fonts" -exclude *.ps1 -force

###What results are considered compliant###
$expectedResults = @()
$expectedResults += "Sabon Roman.TTF"
$expectedResults += "FRANGID_.TTF"

###What Results we actually get###
$values = @()
$values += Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name '"Sabon Roman"'
$values += Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "FRANGID"
 
###Keys we're modifying###
$keyPaths = @()
$keyPaths += "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
$keyPaths += "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

###Properties we're modifying###
$properties = @()
$properties += '"Sabon Roman"' #2
$properties += "FRANGID" #2

###Checking that all keys exist###
$keyStatus = @()
$keyStatus += If(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -ne $true){$false}
$keyStatus += If(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -ne $true){$false}

    ###Property existence check###
 $existenceCheck1 = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" | Select-Object Property | Where-Object {@($_.Property) -contains '"Sabon Roman"'}
 $existenceCheck2 = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" | Select-Object Property | Where-Object {@($_.Property) -contains 'FRANGID'}

 ###Making an array for scalability###
 $existenceArray = 
 @(  @{Attribute="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"; Value=If($null -ne $existenceCheck3){'"Sabon Roman"'}}
     @{Attribute="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"; Value=If($null -ne $existenceCheck4){'FRANGID'}})

###Specifying what we want to read from###            
$existence = $existenceArray.Value

###Putting everything together###
$fullArray = @(
    ($keyPaths.Length-1) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}}
    ($keyPaths.Length-2) | Select-Object @{n="Key";e={$keyPaths[$_]}}, @{n="Property";e={$properties[$_]}}, @{n="Value";e={$values[$_]}}, @{n="ExpectedValue";e={$expectedValues[$_]}})

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
        ###Create key and properties##
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" 
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name '"Sabon Roman"' -Type "String" -Value "Sabon Roman.TTF" -Verbose
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" 
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "FRANGID" -Type "String" -Value "FRANGID_.TTF"

        ###Set Item Properties to expected values###
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name '"Sabon Roman"' -Type "String" -Value "Sabon Roman.TTF" -Verbose
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "FRANGID" -Type "String" -Value "FRANGID_.TTF"
        
    }elseif($incorrectValues -gt "0"){
        ###Set Item Properties to expected values###
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name '"Sabon Roman"' -Type "String" -Value "Sabon Roman.TTF" -Verbose
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "FRANGID" -Type "String" -Value "FRANGID_.TTF"
    }


###Creates path and string for detection
New-Item -Path "HKLM:\Software\" -Name "Intune" -Verbose
New-ItemProperty -Path "HKLM:\Software\Intune" -Name "Remediation_Fonts" -Type String -Value 07162021
Set-ItemProperty -Path "HKLM:\Software\Intune" -Name "Remediation_Fonts" -Value 07162021
