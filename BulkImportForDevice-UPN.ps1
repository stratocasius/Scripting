### Bulk Ops for importing large amount of ObjectIDs from list of device names in .CSV
### https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/groups-bulk-import-members

Install-module -name msonline -force 
Connect-MsolService
$CHGList = Import-Csv -path "C:\Win32 Apps\Scripts\BulkImportGroups\IE\IE11-June2023-Rapid7\IE11Enabled.csv" -Verbose
$ObjectID = @(
    @{ Name = 'version:v1.0'; Expression = { $_.'ObjectId' } }
)
'*'| Select-Object -Property $ObjectID |Export-CSV -Path "C:\Win32 Apps\Scripts\BulkImportGroups\IE\IE11-June2023-Rapid7\IE-June2023-Rapid7GroupIDs.csv" -NoTypeInformation -Append -Force
ForEach ($displayName in $CHGList) {
    Get-MsolDevice -Name $displayName.displayName | Select-Object -Property $ObjectID |Export-CSV -Path "C:\Win32 Apps\Scripts\BulkImportGroups\IE\IE11-June2023-Rapid7\IE-June2023-Rapid7BulkIDs.csv" -NoTypeInformation -Append
}

#######################################################
### Another Option for above 
Connect-AzureAD
$csv = Import-Csv -Path "C:\Win32 Apps\Scripts\BulkImportGroups\IERemovalNeedsRebooted\03012023\IE11-nd310RebootGroupPCs.csv"
$ObjectID=@()
foreach ($DisplayName in $csv){
    $DisplayName
    $ObjectID1 = get-AzureADDevice -Filter "DisplayName eq $DisplayName" | Select ObjectID | ft -HideTableHeaders
    $ObjectID1
    $objectID += $ObjectID1
}
$ObjectID
$ObjectID | Out-File -encoding UTF8 "C:\Win32 Apps\Scripts\BulkImportGroups\IERemovalNeedsRebooted\03012023\IE11-nd310Reboot-BulkObjectID.csv"

$csv2 = Import-Csv -Path "C:\Win32 Apps\Scripts\BulkImportGroups\IERemovalNeedsRebooted\IERemovalNeedsRebooted-pcnamesGroupID.csv"
$Owners=@()
foreach ($UPN in $csv2){
    $DisplayName
    $Owners1 = Get-AzureADDeviceRegisteredOwner -ObjectId $UPN |Select-Object mail
    $Owners1
    $Owners += $Owners1
}
$Owners | Out-File -encoding UTF8 "C:\Win32 Apps\Scripts\BulkImportGroups\IERemovalNeedsRebooted\IERemovalNeedsRebooted-Users.csv"

#####################################################################################################################################
### Build UPN list from device group's object ID.
Connect-AzureAD
$Result=@()
$Members = Get-AzureADGroupMember -ObjectId "3745b3e9-9be7-48bc-83d9-fc64c7c73e23"
foreach ($Member in $Members) {
    $DeviceOwner = $Member|Get-AzureADDeviceRegisteredOwner
    $deviceprops = [ordered] @{
        DeviceDisplayName = $Member.DisplayName
        DeviceObjectID = $Member.ObjectId
        OwnerDisplayName = $DeviceOwner.DisplayName
        OwnerUserPrincipalName = $DeviceOwner.UserPrincipalName
        OwnerObjectID = $DeviceOwner.ObjectId 
    }
    $deviceobj = new-object -Type PSObject -Property $deviceprops
    $Result += $deviceobj
}
$Result 
$Result | Export-CSV "C:\Win32 Apps\Scripts\BulkImportGroups\IE\IE11-June2023-Rapid7\IE11Enabled-DeviceOwners.csv" -verbose

