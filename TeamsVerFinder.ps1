# Get all processes with the name msedgewebview2.exe
$processes = Get-WmiObject Win32_Process -Filter "name = 'msedgewebview2.exe'"

# Check each process to see if its command line contains 'MSTeams'
foreach ($process in $processes) {
    if ($process.CommandLine -like "*MSTeams*") {
        # Get the username of the process owner
        $ownerInfo = $process.GetOwner()
        $owner = "$($ownerInfo.Domain)\$($ownerInfo.User)"
        Write-Output "New Teams Running under user $owner"
        ##exit 1
    }
}

# If no process is found with MSTeams in the command line
Write-Output "New Teams not running"
##exit 0
