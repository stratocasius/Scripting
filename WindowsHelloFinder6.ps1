# Getting the logged on user's SID
$loggedOnUserSID = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value
# Registry path for the PIN credential provider
$credentialProvider = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{D6886603-9D2F-4EB2-B667-1971041FA96B}"
if (Test-Path -Path $credentialProvider) {
    $userSIDs = Get-ChildItem -Path $credentialProvider
    $items = $userSIDs | Foreach-Object { Get-ItemProperty $_.PsPath }
}

if(-NOT[string]::IsNullOrEmpty($loggedOnUserSID)) {
    # If multiple SID's are found in registry, look for the SID belonging to the logged on user
    if ($items.GetType().IsArray) {
        # LogonCredsAvailable needs to be set to 1, indicating that the credential provider is in use
        if ($items.Where({$_.PSChildName -eq $loggedOnUserSID}).LogonCredsAvailable -eq 1) {
            Write-Output "[Multiple SIDs]: All good. PIN credential provider found for LoggedOnUserSID. This indicates that user is enrolled into WHfB."
            exit 0                    
        }
        # If LogonCredsAvailable is not set to 1, this will indicate that the PIN credential provider is not in use
        elseif ($items.Where({$_.PSChildName -eq $loggedOnUserSID}).LogonCredsAvailable -ne 1) {
            Write-Output "[Multiple SIDs]: Not good. PIN credential provider NOT found for LoggedOnUserSID. This indicates that the user is not enrolled into WHfB."
            exit 1
        }
    }
}