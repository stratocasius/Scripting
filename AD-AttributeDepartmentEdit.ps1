### Edits User AD object attribute for Department field from .csv
$Results = @()
$users = Import-Csv -Path "C:\temp\attributesTESTDEPT.csv"

ForEach ($user in $users)
{
    Get-ADUser -Identity $user.Name | Set-ADUser -Department $user.Department -Verbose
    
  }





  


  ### Edits User AD object attribute for Department field from .csv
$csvPath = "C:\temp\attributesTESTDEPT.csv"
$Attributes = Import-Csv -Path $csvPath
foreach($user in $Attributes){
    Get-ADUser -Filter "sAMAccountName -eq $($user.Department)" | Set-ADUser -Department $user.Department
}





  ### Edits User AD object attribute for Department field from .csv
$Results = @()
$users = Import-Csv -Path "C:\temp\ADattributesTESTMGR.csv"

ForEach ($user in $users)
{
    Get-ADUser -Identity $user.Name | Set-ADUser -Manager $user.Manager -Verbose
    
  }