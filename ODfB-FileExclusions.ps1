### OneDrive for Business File extenion exclusion by registry.
# Define the file types you want to exclude from syncing (replace with your desired file extensions)
$fileTypesToExclude = @(".pst")

# Registry path for OneDrive for Business sync client settings
$registryPath = "HKCU:\SOFTWARE\Microsoft\OneDrive\"

# Check if the OneDrive registry key exists, and create it if it doesn't
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Create a new registry entry with the excluded file types
New-ItemProperty -Path $registryPath -Name "ExcludedFileTypes" -Value $fileTypesToExclude -PropertyType MultiString -Force | Out-Null

# Optionally, restart the OneDrive process to apply the changes immediately
Stop-Process -Name "OneDrive" -Force
Start-Process "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" -Verbose


#########################################################################################################
### OneDrive for Business File extenion exclusion.
#Parameters
$TenantAdminURL = "https://crescent-admin.sharepoint.com"
 
#Connect to Admin Center
Connect-SPOService -Url $TenantAdminURL -Credential (Get-credential)
 
#Set blocked File types
Set-SPOTenantSyncClientRestriction -ExcludedFileExtensions "exe;mp3;mp4"


#Read more: https://www.sharepointdiary.com/2019/09/onedrive-for-business-block-syncing-specific-file-types.html#ixzz89e7sonxS

#########################################################################################################
### Another way

# Connect to SharePoint Online Management Shell (you might need to install it first)
Connect-SPOService -Url https://your-tenant-admin.sharepoint.com

# Define the file types you want to exclude from syncing (replace with your desired file extensions)
$fileTypesToExclude = @(".tmp", ".bak", ".log", ".exe")

# Get the current sync client restriction settings
$tenantSettings = Get-SPOTenantSyncClientRestriction

# If there are existing restrictions, add the file types to the exclusion list
if ($tenantSettings -ne $null) {
    $excludedFileTypes = $tenantSettings.ExcludedFileExtensions
    $excludedFileTypes += $fileTypesToExclude
    $tenantSettings.ExcludedFileExtensions = $excludedFileTypes
}
else {
    # If there are no existing restrictions, create a new object with the exclusion list
    $tenantSettings = New-Object Microsoft.Online.SharePoint.TenantAdministration.SPOSyncClientRestriction
    $tenantSettings.ExcludedFileExtensions = $fileTypesToExclude
}

# Set the updated sync client restriction settings
Set-SPOTenantSyncClientRestriction -SyncClientRestriction $tenantSettings


