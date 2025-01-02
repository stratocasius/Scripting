get-childitem -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{D6886603-9D2F-4EB2-B667-1971041FA96B}" -recurse -ErrorAction SilentlyContinue | Where-Object {$_.Name -like "LogonCredsAvailable"} -Verbose
get-childitem -recurse "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{D6886603-9D2F-4EB2-B667-1971041FA96B}" | 
get-itemproperty | where { $_ -match 'LogonCredsAvailable' } 
Write-Output $_