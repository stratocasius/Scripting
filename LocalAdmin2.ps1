# Define the users to exclude
$excludedUsers = @("HDAdmin", "PCAdministrator", "ZZZdmi", "Domain Admins", "JL Desktop Admin", "LocalAdmins")

# Get the members of the local administrators group
$adminsGroup = [ADSI]("WinNT://./Administrators,group")
$members = @()

foreach ($member in $adminsGroup.Invoke("Members")) {
    $memberName = $member.GetType().InvokeMember("Name", 'GetProperty', $null, $member, $null)
    if ($excludedUsers -notcontains $memberName) {
        $members += $memberName
    }
}

# Write all members to the log file on one line
if ($members.Count -eq 0) {
    Write-Output "No unauthorized local administrators found."
} else {
    $membersLine = $members -join ", "
    Write-Output "Unauthorized local administrators: $membersLine"
}