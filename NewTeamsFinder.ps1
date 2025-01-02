$NewTeamsPath = "C:\Program Files\WindowsApps\MSTeams_23285.3607.2525.937_x64__8wekyb3d8bbwe\ms-teams.exe"

if (Test-Path $NewTeamsPath) {
    Write-Output "New Teams is installed."
} else {
    Write-Output "Not installed."
}
