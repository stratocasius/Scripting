Remove-AzureADDevice -ObjectId "99a1915d-298f-42d1-93ae-71646b85e2fa"
Install-Module AzureAD
Get-ChildItem -Path Cert:\CurrentUser\My | where { $_.subject -eq "CN=MysubjectName" } | Remove-Item