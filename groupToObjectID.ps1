# This script will take an azure group, gather its members and collect a list of assigned machines 
# and machine ObjectID's. Useful for creating bulk imports for groups
# Usage - groupToObjectID.ps1 -groupObjectId d540f7be-0e6e-4123-9987-02dfefb23488 .\pilot-12042023.csv
### or .\groupToDeviceID1.ps1 -Groupobjectid "55600cf8-5214-4264-af96-9ff773bca589" -csvoutputpath .\PilotOfficeDevices-072520205.csv
# -groupObjectId is the ObjectID for the group that you want to run the script against, last arguement is
# is the path to the output csv
param(
    [Parameter(Mandatory=$true)]
    [string]$groupObjectId,

    [Parameter(Mandatory=$true)]
    [string]$csvOutputPath
)

# Required modules
Import-Module AzureAD
Import-Module Microsoft.Graph.Intune

# Authenticate with Azure
Connect-MSGraph
Connect-AzureAD

function Get-RecursiveGroupMembers {
    param (
        [string]$ObjectId
    )

    $members = Get-AzureADGroupMember -ObjectId $ObjectId -All $true
    $users = @()

    foreach ($member in $members) {
        if ($member.ObjectType -eq "User") {
            $userDetails = Get-AzureADUser -ObjectId $member.ObjectId
            $users += $userDetails
        } elseif ($member.ObjectType -eq "Group") {
            $users += Get-RecursiveGroupMembers -ObjectId $member.ObjectId
        }
    }

    return $users
}

# Check if group exists
$group = Get-AzureADGroup -ObjectId $groupObjectId

if (-not $group) {
    Write-Error "Group not found!"
    exit
}

# Fetch members recursively
$groupMembers = Get-RecursiveGroupMembers -ObjectId $group.ObjectId

# Empty array to store results
$results = @()

foreach ($member in $groupMembers) {
    $intuneDevices = Get-IntuneManagedDevice -Filter "userPrincipalName eq '$($member.UserPrincipalName)' and operatingSystem eq 'Windows'" | Select-Object id, userPrincipalName, deviceName, azureADDeviceId
    
    foreach ($device in $intuneDevices) {
        $azureObject = Get-AzureADDevice -Filter "deviceId eq guid'$($device.azureADDeviceId)'"
        if ($azureObject) {
            $results += [PSCustomObject]@{
                'UserDisplayName' = $member.DisplayName
                'UserUPN'         = $member.UserPrincipalName
                'IntuneDeviceId'  = $device.id
                'DeviceName'      = $device.deviceName
                'AzureADDeviceId' = $device.azureADDeviceId
                'AzureADObjectId' = $azureObject.ObjectId
            }
        } else {
            Write-Warning "Device with ID $($device.azureADDeviceId) not found."
        }
    }
}

# Write to CSV
$results | Export-Csv -Path $csvOutputPath -NoTypeInformation

Write-Output "Script completed!"