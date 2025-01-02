# Import the MSGraphFunctions module
Import-Module -Name MSGraphFunctions

# Authenticate with the Microsoft Graph API
# Replace with your own values
$clientId = "a0114c5c-61e8-4306-9405-cd112a615ef6"
$clientSecret = "e-H8Q~JAhkW8_8gYWv3LAZHfpZMvtG-5nduEUbr~"
$tenantId = "6ab77482-4dda-43b3-9e50-82db3e426c2c"
Connect-MSGraph -ClientId $clientId -ClientSecret $clientSecret -TenantId $tenantId

# Define the user's UPN for whom you want to retrieve assignments
$userUPN = "randy.doss@jacksonlewis.com"

# Get the user's ID from their UPN
$user = Get-MSGraphUser -Filter "userPrincipalName eq '$userUPN'"

if ($user -ne $null) {
    $userId = $user.Id
    Write-Host "User ID: $userId"

    # List all app assignments for the user
    $appAssignments = Get-MSGraphUserAppAssignments -UserId $userId
    if ($appAssignments.Count -gt 0) {
        Write-Host "Application Assignments for $userUPN:"
        $appAssignments | ForEach-Object {
            Write-Host "Assignment ID: $($_.id)"
            Write-Host "App Name: $($_.targetDisplayName)"
            Write-Host "Assignment Type: $($_.targetType)"
            Write-Host "------------------------"
        }
    } else {
        Write-Host "No application assignments found for $userUPN."
    }

    # List all CSP assignments for the user
    $cspAssignments = Get-MSGraphUserCSPAssignments -UserId $userId
    if ($cspAssignments.Count -gt 0) {
        Write-Host "CSP Assignments for $userUPN:"
        $cspAssignments | ForEach-Object {
            Write-Host "Assignment ID: $($_.id)"
            Write-Host "CSP Name: $($_.targetDisplayName)"
            Write-Host "Assignment Type: $($_.targetType)"
            Write-Host "------------------------"
        }
    } else {
        Write-Host "No CSP assignments found for $userUPN."
    }
} else {
    Write-Host "User with UPN $userUPN not found."
}
