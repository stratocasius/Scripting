$remoteComputer = "LT6511"
$session = New-PSSession -ComputerName $remoteComputer

# Get the session ID of the user to log off
Invoke-Command -Session $session -ScriptBlock {
    $userName = "UserToLogOff"
    $sessionId = (Get-WmiObject -Class Win32_LogonSession | 
                  Where-Object { $_.LogonType -eq 2 } | 
                  ForEach-Object {
                      $logonID = $_.LogonId
                      $user = (Get-WmiObject -Class Win32_LoggedOnUser | 
                               Where-Object { $_.LogonId -eq $logonID } | 
                               ForEach-Object {
                                   (Get-WmiObject -Class Win32_Account -Filter "SID='$($_.SID)'")
                               }).Name
                      if ($user -eq $userName) {
                          $_.LogonId
                      }
                  }).ToString()
    $sessionId
}

# Log off the user
Invoke-Command -Session $session -ScriptBlock {
    param ($sessionId)
    logoff $sessionId
} -ArgumentList $sessionId

Remove-PSSession -Session $session
