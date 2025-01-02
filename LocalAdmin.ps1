# Get the members of the local administrators group
$adminsGroup = [ADSI]("WinNT://./Administrators,group")
$members = @()

foreach ($member in $adminsGroup.Invoke("Members")) {
    $memberName = $member.GetType().InvokeMember("Name", 'GetProperty', $null, $member, $null)
    $members += $memberName
    Write-Output "Admins found: $memberName"
}