param (
    [Parameter(Mandatory=$true)]
    [string]$groupObjectId,

    [Parameter(Mandatory=$true)]
    [string]$csvOutputPath
)

# Required modules
Import-Module AzureAD
Import-Module Microsoft.Graph.Intune
Update-MSGraphEnvironment -AppId "13a974cb-f98c-4f05-be8f-fa4dcf62178b"
# Authenticate with Azure
# $credential = Get-Credential
Connect-AzureAD
Connect-MSGraph
function Get-RecursiveGroupMembers {
    param (
        [string]$ObjectId
    )

    $members = Get-AzureADGroupMember -ObjectId $ObjectId -All $true
    $users = @()

    foreach ($member in $members) {
        if ($member.ObjectType -eq "User") {
            $users += $member
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

# ...

# For each member, get Intune device's object ID
foreach ($member in $groupMembers) {
    Write-Output "Processing user: $($member.UserPrincipalName)"

    # Filtering for Windows devices using an additional filter condition
    $intuneDevices = Get-IntuneManagedDevice -Filter "userPrincipalName eq '$($member.UserPrincipalName)' and operatingSystem eq 'Windows'" | Select-Object id, userPrincipalName, deviceName, azureADDeviceId
    
    if (-not $intuneDevices) {
        Write-Output "No devices found for user $($member.UserPrincipalName)"
        continue
    }
    
    foreach ($device in $intuneDevices) {
        if (-not $device.id) {
            Write-Output "No device ID for user $($member.UserPrincipalName)"
            continue
        }

        Write-Output "Windows device found for user $($member.UserPrincipalName): $($device.id) - $($device.deviceName)"
        
        $results += [PSCustomObject]@{
            'UserUPN'         = $member.UserPrincipalName
            'IntuneDeviceId'  = $device.id
            'DeviceName'      = $device.deviceName
            'AzureADDeviceId' = $device.azureADDeviceId
        }
    }
}

# Write to CSV
$results | Export-Csv -Path $csvOutputPath -NoTypeInformation

Write-Output "Script completed!"
