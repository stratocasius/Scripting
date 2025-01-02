# Connect to Exchange Online if not already connected
# You might need to install the Exchange Online Management Module first
# Install-Module -Name ExchangeOnlineManagement
# Connect-ExchangeOnline
 
# Function to recursively get group members
function Get-GroupMembers {
    param(
        [string]$Identity
    )
 
    $members = Get-DistributionGroupMember -Identity $Identity -ResultSize Unlimited
    foreach ($member in $members) {
        [PSCustomObject]@{
            Group    = $Identity
            Member   = $member.PrimarySmtpAddress
            Type     = $member.RecipientType
        }
 
        # If the member is also a group, recurse
        if ($member.RecipientType -eq "MailUniversalDistributionGroup" -or $member.RecipientType -eq "MailUniversalSecurityGroup" -or $member.RecipientType -eq "MailNonUniversalGroup") {
            Get-GroupMembers -Identity $member.PrimarySmtpAddress
        }
    }
}
 
# Get all groups
$allGroups = Get-DistributionGroup -ResultSize Unlimited
 
# Collect information from all groups
$results = foreach ($group in $allGroups) {
    Get-GroupMembers -Identity $group.PrimarySmtpAddress
}
 
# Output results
$results | Export-Csv -Path "C:\Path\To\Your\Output\file.csv" -NoTypeInformation