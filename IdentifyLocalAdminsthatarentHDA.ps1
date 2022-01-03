###Identify Local Admins that aren't HDAdmin###

$nonHDAdmins = Get-LocalUser | Where-Object {$_.Name -notlike "HDAdmin"} | Where-Object {$_.Enabled -eq $true}

###Specify the Name Property##

$badAdminNames = $nonHDAdmins.Name

###Disable all the non HDAdmins###

foreach($admin in $badAdminNames){

    Disable-LocalUser -Name $admin

    Write-Host "Disabling the $admin account" -ForegroundColor Green

}