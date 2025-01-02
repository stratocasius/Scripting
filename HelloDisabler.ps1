# Define the remote computer and user
$remoteComputer = "REMOTE_COMPUTER_NAME"
$username = "USERNAME"

# Disable Windows Hello for Business
Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
    $userSID = (New-Object System.Security.Principal.NTAccount($using:username)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork\$($userSID)"
    
    # Check if the registry key exists
    if (Test-Path $regPath) {
        # Disable Windows Hello for Business
        New-ItemProperty -Path $regPath -Name "Enabled" -Value 0 -PropertyType DWORD -Force
        Write-Output "Windows Hello for Business disabled for $($using:username)."
    } else {
        Write-Output "Registry key not found. Windows Hello for Business may not be configured for $($using:username)."
    }
} -Credential (Get-Credential)
