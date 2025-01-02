# Define the target user's UPN to which the inactive users' devices will be assigned
$TargetUserUPN = "newuser@domain.com"

# Calculate date 30 days ago
$InactiveDate = (Get-Date).AddDays(-30)

# Get inactive users based on LastLogonDate
$InactiveUsers = Get-ADUser -Filter {LastLogonDate -lt $InactiveDate} -Properties LastLogonDate

# Loop through inactive users and change their devices' UPN
foreach ($user in $InactiveUsers) {
    $devices = Get-ADUser $user -Properties memberof | Select-Object -ExpandProperty memberof | Where-Object {$_ -like "CN=Device*"}

    foreach ($device in $devices) {
        Set-ADUser -Identity $device -UserPrincipalName $TargetUserUPN
        Write-Output "Changed UPN for device $device to $TargetUserUPN"
    }
}
