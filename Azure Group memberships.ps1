# Install and import AzureAD module if not already installed
if (-not (Get-Module -Name AzureAD -ListAvailable)) {
    Install-Module -Name AzureAD -Force -AllowClobber
}
Import-Module -Name AzureAD

# Function to recursively get group members and counts
function Get-RecursiveGroupMembersCount {
    param (
        [string]$GroupId,
        [string]$Indent = ""
    )

    # Get members of the group
    $groupMembers = Get-AzureADGroupMember -ObjectId $GroupId -All $true

    # Output group count
    $groupCount = $groupMembers.Count
    Write-Output "$Indent$groupCount members"

    # Output members
    foreach ($member in $groupMembers) {
        $output = New-Object PSObject -Property @{
            GroupName = $GroupId
            MemberName = $member.DisplayName
            MemberType = $member.ObjectType
        }
        $output | Export-Csv -Append -Path "C:\Temp\AzureGroupMembers.csv" -NoTypeInformation -Force

        if ($member.ObjectType -eq "Group") {
            # If member is a group, recursively get its members and counts
            Get-RecursiveGroupMembersCount -GroupId $member.ObjectId -Indent "$Indent  "
        }
    }
}

# Get all Azure AD groups
$groups = Get-AzureADGroup -All $true

# Iterate through each group and get its members recursively
foreach ($group in $groups) {
    Write-Output "Group: $($group.DisplayName)"
    Get-RecursiveGroupMembersCount -GroupId $group.ObjectId
    Write-Output ""
}
