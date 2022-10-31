### Bulk Ops for importing large amount of ObjectIDs from list of device names in .CSV
### https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/groups-bulk-import-members

Install-module -name msonline -force 
Connect-MsolService
$CHGList = Import-Csv -path "C:\Win32 Apps\Scripts\BulkImportGroups\LiteraUpdatedFiles\LiterapdateFilesPCnames.csv" -Verbose
$ObjectID = @(
    @{ Name = 'version:v1.0'; Expression = { $_.'ObjectId' } }
)
'*'| Select-Object -Property $ObjectID |Export-CSV -Path "C:\Win32 Apps\Scripts\BulkImportGroups\LiteraUpdatedFiles\LiterapdateFilesGroupID.csv" -NoTypeInformation -Append -Force
ForEach ($displayName in $CHGList) {
    Get-MsolDevice -Name $displayName.displayName | Select-Object -Property $ObjectID |Export-CSV -Path "C:\Win32 Apps\Scripts\BulkImportGroups\LiteraUpdatedFiles\LiterapdateBulkIDs.csv" -NoTypeInformation -Append
}