# Import the Active Directory module
Import-Module ActiveDirectory

# Define the number of days to consider a computer as inactive
$inactiveDays = 90

# Calculate the date corresponding to 90 days ago from today
$dateThreshold = (Get-Date).AddDays(-$inactiveDays)

# Define the target OU where inactive computers will be moved
$targetOU = "OU=Disabled,DC=yourdomain,DC=com"

# Get all computer objects in the domain
$computers = Get-ADComputer -Filter * -Property LastLogonDate

foreach ($computer in $computers) {
    # Check if the LastLogonDate is older than the threshold
    if ($computer.LastLogonDate -lt $dateThreshold) {
        # Move the computer object to the target OU
        try {
            Move-ADObject -Identity $computer.DistinguishedName -TargetPath $targetOU
            Write-Output "Moved computer: $($computer.Name) to $targetOU"
        } catch {
            Write-Error "Failed to move computer: $($computer.Name) - $($_.Exception.Message)"
        }
    }
}
