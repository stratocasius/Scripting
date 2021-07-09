###Remediation Windows HKCU Script###

###Skip error messages to continue script###
$ErrorActionPreference = "SilentlyContinue"

###What keyPaths$keyPaths are considered compliant###
$expectedValues = @()
$expectedValues += "0"
$expectedValues += "0"
$expectedValues += "1"
$expectedValues += "0"
$expectedValues += "0"
$expectedValues += "1"
$expectedValues += "MSEdgeHTM"
$expectedValues += "MSEdgeHTM"
$expectedValues += "0"
$expectedValues += "0"
$expectedValues += "1"
$expectedValues += "true"
$expectedValues += "2"
$expectedValues += "CA-2V8C78SD"

###What Results we actually get###
$values = @()
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" -Name "1407"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" -Name "1A00"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "Hidden"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Nuance\PDF\Nuance Power PDF\Preference" -Name "PrintWithSysDefaultPrinter"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "ProgId"
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name "ProgId"
$values += Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable" #0
$values += Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" #0
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "SyncFavoritesBetweenIEAndMicrosoftEdge" #1
$values += Get-ItemPropertyValue -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "useMapi" #true
$values += Get-ItemPropertyValue -Path "HKCU:\Software\Control Panel\Desktop" -Name "WallpaperStyle" #2
$values += Get-ItemPropertyValue -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "LoginRepoID" #CA-2V8C78SD

###Keys we're modifying###
$keyPaths = @()
$keyPaths += "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2"
$keyPaths += "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
$keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$keyPaths += "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
$keyPaths += "HKCU:\Software\Nuance\PDF\Nuance Power PDF\Preference"
$keyPaths += "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
$keyPaths += "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice"
$keyPaths += "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"
$keyPaths += "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
$keyPaths += "HKCU:\Software\Policies\Microsoft\MicrosoftEdge\Main"
$keyPaths += "HKCU:\Software\NetVoyage\NetDocuments"
$keyPaths += "HKCU:\Software\Control Panel\Desktop"
$keyPaths += "HKCU:\Software\NetVoyage\NetDocuments"

###Properties we're modifying###
    $properties = @()
    $properties += "1407"
    $properties += "1A00"
    $properties += "AppsUseLightTheme"
    $properties += "Hidden"
    $properties += "PeopleBand"
    $properties += "PrintWithSysDefaultPrinter"
    $properties += "ProgId"
    $properties += "ProgId"
    $properties += "ProxyEnable"
    $properties += "SearchboxTaskbarMode"
    $properties += "SyncFavoritesBetweenIEAndMicrosoftEdge"
    $properties += "useMapi"
    $properties += "WallpaperStyle"
    $properties += "LoginRepoID"

   ###Checking that all keys exist###
   $keyStatus = @()
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Nuance\PDF\Nuance Power PDF\Preference" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "KCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Policies\Microsoft\MicrosoftEdge\Main" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\NetVoyage\NetDocuments" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\Software\Control Panel\Desktop" -ne $true){$false}
   $keyStatus += If(Test-Path -Path "HKCU:\SOFTWARE\NetVoyage\NetDocuments" -ne $true){$false}

      ###Property existence check###
      $existenceCheck1 = Get-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" | Select-Object Property | Where-Object {@($_.Property) -contains '1407'}
      $existenceCheck2 = Get-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" | Select-Object Property | Where-Object {@($_.Property) -contains '1A00'}
      $existenceCheck3 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" | Select-Object Property | Where-Object {@($_.Property) -contains 'AppsUseLightTheme'}
      $existenceCheck4 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" | Select-Object Property | Where-Object {@($_.Property) -contains 'Hidden'}
      $existenceCheck5 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Select-Object Property | Where-Object {@($_.Property) -contains 'PeopleBand'}
      $existenceCheck6 = Get-Item -Path "HKCU:\Software\Nuance\PDF\Nuance Power PDF\Preference" | Select-Object Property | Where-Object {@($_.Property) -contains 'PrintWithSysDefaultPrinter'}
      $existenceCheck7 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" | Select-Object Property | Where-Object {@($_.Property) -contains 'ProgId'}
      $existenceCheck8 = Get-Item -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" | Select-Object Property | Where-Object {@($_.Property) -contains 'ProgId'}
      $existenceCheck9 = Get-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" | Select-Object Property | Where-Object {@($_.Property) -contains 'ProxyEnable'}
      $existenceCheck10 = Get-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" | Select-Object Property | Where-Object {@($_.Property) -contains 'SearchboxTaskbarMode'}
      $existenceCheck11 = Get-Item -Path "HKCU:\Software\Policies\Microsoft\MicrosoftEdge\Main" | Select-Object Property | Where-Object {@($_.Property) -contains 'SyncFavoritesBetweenIEAndMicrosoftEdge'}
      $existenceCheck12 = Get-Item -Path "HKCU:\Software\NetVoyage\NetDocuments" | Select-Object Property | Where-Object {@($_.Property) -contains 'useMapi'}
      $existenceCheck13 = Get-Item -Path "HKCU:\Software\Control Panel\Desktop" | Select-Object Property | Where-Object {@($_.Property) -contains 'WallpaperStyle'}
      $existenceCheck14 = Get-Item -Path "HKCU:\Software\NetVoyage\NetDocuments" | Select-Object Property | Where-Object {@($_.Property) -contains 'LoginRepoID'}
      
    ###Making an array for scalability###
    $existenceArray = 
        @(  @{Attribute="HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2"; Value=If($null -ne $existenceCheck1){'1407'}}
            @{Attribute="HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"; Value=If($null -ne $existenceCheck2){'1A00'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Value=If($null -ne $existenceCheck3){'AppsUseLightTheme'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Value=If($null -ne $existenceCheck4){'Hidden'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"; Value=If($null -ne $existenceCheck5){'PeopleBand'}}
            @{Attribute="HKCU:\Software\Nuance\PDF\Nuance Power PDF\Preference"; Value=If($null -ne $existenceCheck6){'PrintWithSysDefaultPrinter'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"; Value=If($null -ne $existenceCheck7){'ProgId'}}
            @{Attribute="HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice"; Value=If($null -ne $existenceCheck7){'ProgId'}}
            @{Attribute="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"; Value=If($null -ne $existenceCheck8){'ProxyEnable'}}
            @{Attribute="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; Value=If($null -ne $existenceCheck9){'SearchboxTaskbarMode'}}
            @{Attribute="HKCU:\Software\Policies\Microsoft\MicrosoftEdge\Main"; Value=If($null -ne $existenceCheck9){'SyncFavoritesBetweenIEAndMicrosoftEdge'}}
            @{Attribute="HKCU:\Software\NetVoyage\NetDocuments"; Value=If($null -ne $existenceCheck9){'useMapi'}}
            @{Attribute="HKCU:\Software\Control Panel\Desktop"; Value=If($null -ne $existenceCheck9){'WallpaperStyle'}}
            @{Attribute="HKCU:\Software\NetVoyage\NetDocuments"; Value=If($null -ne $existenceCheck9){'LoginRepoID'}})

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
               
                ## $incorrectValues = $valueCheck.Count
                $missingProperties = "$($properties.Count)" - "$($existence.Count)"
                $incorrectValues = $valueCheck.Count
                $missingKeys = $statusCheck.Count

    ###If either the existence check or value check contain a $false value, create all reg keys and properties###
    If($missingKeys -gt "0" -or $missingProperties -gt "0"){
        ###Create keys and properties##
        New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" 
        New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" -Name "1407" -Type DWORD -Value 00000000 
        New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" 
        New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" -Name "1A00" -Type DWORD -Value 00000000
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"-Name "AppsUseLightTheme" -Type DWORD -Value 00000001
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"-Name "Hidden" -Type DWORD -Value 00000000
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWORD -Value 00000000
        New-Item -Path "HKCU:\Software\Nuance\PDF\Nuance Power PDF\Preference"
        New-ItemProperty -Path "HKCU:\Software\Nuance\PDF\Nuance Power PDF\Preference" -Name "PrintWithSysDefaultPrinter" -Type DWORD -Value 00000001
        New-Item -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "ProgId" -Type String -Value MSEdgeHTM #Change to MSEdgeHTM when needing default for Edge.
        New-Item -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice"
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name "ProgId" -Type String -Value MSEdgeHTM
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable" -Type DWORD -Value 00000000
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" 
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWORD -Value 00000000
        New-Item -Path "HKCU:\Software\Policies\Microsoft\MicrosoftEdge\Main"
        New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\MicrosoftEdge\Main"-Name "SyncFavoritesBetweenIEAndMicrosoftEdge" -Type DWORD -Value 00000001
        New-Item -Path "HKCU:\Software\NetVoyage\NetDocuments"
        New-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "useMapi" -Type String -value "true"
        New-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "LoginRepoID" -Type String -value "CA-2V8C78SD"
        New-Item -Path "HKCU:\Software\Control Panel\Desktop"
        New-ItemProperty -Path "HKCU:\Software\Control Panel\Desktop" -Name "WallpaperStyle" -Type DWORD -value "2"
        
        }  

            ###Set Item Properties to expected values###
             Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" -Name "1407" -Type DWORD -Value 00000000 
             Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" -Name "1A00" -Type DWORD -Value 00000000
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"-Name "AppsUseLightTheme" -Type DWORD -Value 00000001
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"-Name "Hidden" -Type DWORD -Value 00000000
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWORD -Value 00000000
             Set-ItemProperty -Path "HKCU:\Software\Nuance\PDF\Nuance Power PDF\Preference" -Name "PrintWithSysDefaultPrinter" -Type DWORD -Value 00000001
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "ProgId" -Type String -Value MSEdgeHTM #Change to MSEdgeHTM when needing default for Edge.
             Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name "ProgId" -Type String -Value MSEdgeHTM #Change to MSEdgeHTM when needing default for Edge.
             Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable" -Type DWORD -Value 00000000
             Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "SearchboxTaskbarMode" -Type DWORD -Value 00000000
             Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "SyncFavoritesBetweenIEAndMicrosoftEdge" -Type DWORD -Value 00000001
             Set-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "useMapi" -Type String -value "true"
             Set-ItemProperty -Path "HKCU:\Software\Control Panel\Desktop" -Name "WallpaperStyle" -Type DWORD -value "2" 
             Set-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "LoginRepoID" -Type String -value "CA-2V8C78SD" 

    elseif($incorrectValues -gt "0"){
        ###Set Item Properties to expected values###
        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" -Name "1407" -Type DWORD -Value 00000000 
        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" -Name "1A00" -Type DWORD -Value 00000000
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"-Name "AppsUseLightTheme" -Type DWORD -Value 00000001
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"-Name "Hidden" -Type DWORD -Value 00000000
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWORD -Value 00000000
        Set-ItemProperty -Path "HKCU:\Software\Nuance\PDF\Nuance Power PDF\Preference" -Name "PrintWithSysDefaultPrinter" -Type DWORD -Value 00000001
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "ProgId" -Type String -Value MSEdgeHTM #Change to MSEdgeHTM when needing default for Edge.
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name "ProgId" -Type String -Value MSEdgeHTM #Change to MSEdgeHTM when needing default for Edge.
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable" -Type DWORD -Value 00000000
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "SearchboxTaskbarMode" -Type DWORD -Value 00000000
        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "SyncFavoritesBetweenIEAndMicrosoftEdge" -Type DWORD -Value 00000001
        Set-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "useMapi" -Type String -value "true"
        Set-ItemProperty -Path "HKCU:\Software\Control Panel\Desktop" -Name "WallpaperStyle" -Type DWORD -value "2"
        Set-ItemProperty -Path "HKCU:\Software\NetVoyage\NetDocuments" -Name "LoginRepoID" -Type String -value "CA-2V8C78SD"

}             

###Creates path and string for detection
New-Item -Path "HKCU:\Software\" -Name "Intune"
New-ItemProperty -Path "HKCU:\Software\Intune" -Name "Remediation_Windows" -Type String -Value 01222021