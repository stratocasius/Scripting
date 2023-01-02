### Edits User AD object attribute for Manager field from .csv
$Results = @()
$users = Import-Csv -Path "C:\temp\AD-ManagerTEST.csv"

ForEach ($user in $users)
{
    Get-ADUser -Identity $user.Name | Set-ADUser -Manager $user.Manager -Verbose
    
  }


### Edits User AD object attribute for Department field from .csv
$Results = @()
$users = Import-Csv -Path "C:\temp\AD-DepartmentTEST.csv"

ForEach ($user in $users)
{
    Get-ADUser -Identity $user.Name | Set-ADUser -Department $user.Department -Verbose
    
  }