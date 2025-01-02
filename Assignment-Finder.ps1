Install-Module -Name MSGraphFunctions -Scope CurrentUser


# Import the MSGraphFunctions module
Import-Module -Name MSGraphFunctions

# Authenticate with the Microsoft Graph API
# Replace with your own values
$clientId = "YourClientId"
$clientSecret = "YourClientSecret"
$tenantId = "6ab77482-4dda-43b3-9e50-82db3e426c2c"
Connect-MSGraph -ClientId $clientId -ClientSecret $clientSecret -TenantId $tenantId

# Define the user's UPN for whom you want to list assignments
$userUPN = "randy.dossr@jacksonlewis.com"

# Get the user's ID from their UPN
$user = Get-MSGraphUser -Filter "userPrincipalName eq '$userUPN'"

if ($user -ne $null) {
    $userId = $user.Id
    Write-Host "User ID: $userId"

    # List all assignments for the user
    $assignments = Get-MSGraphUserAppAssignments -UserId $userId
    if ($assignments.Count -gt 0) {
        Write-Host "Assignments for $userUPN:"
        $assignments | ForEach-Object {
            Write-Host "Assignment ID: $($_.id)"
            Write-Host "App or Policy Name: $($_.targetDisplayName)"
            Write-Host "Assignment Type: $($_.targetType)"
            Write-Host "------------------------"
        }
    } else {
        Write-Host "No assignments found for $userUPN."
    }
} else {
    Write-Host "User with UPN $userUPN not found."
}
