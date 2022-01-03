#Import the ConfigurationManager.psd1 module 

Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"

#Set the current location to be the site code.

Set-Location "RKO:"

 

#$ErrorActionPreference= 'silentlycontinue'

#Get the content of the CSV file

$Computers = Import-Csv "C:\Users\Barksdae\Downloads\VM_Windows_servers.csv"

 

#Loop through each Device and perform actions

Foreach ($Computer in $Computers) {

    #Get Device Resource ID

    $ResourceID = (Get-CMDevice -name $($Computer).hostname).ResourceID

    #Add the Device to the Collection specified

    Write-Host "Adding Machine $($Computer.Name) ResourceID: $ResourceID" -ForegroundColor Yellow

    add-cmdevicecollectiondirectmembershiprule -CollectionId "RKO00415" -resourceid $ResourceID -Verbose 

 

} 

#Set location of script back to script root.

Set-Location $PSScriptRoot