$csvPath = "C:\temp\attributesTESTDEPT.csv"
$Attributes = Import-Csv -Delimiter ";" -Path $csvPath

foreach($user in $Attributes){
    # Find user
    $ADUser = Get-ADUser -Filter "SamAccountName -eq $_.Name"
    if ($ADUser){
        Set-ADUser -Identity $ADUser -Department $user.Department
    }else{
        Write-Warning ("Failed to update " + $($user.name))
    }
}






    $adUser = Get-ADUser -Filter "SamAccountName -eq '$($user.EmployeeUsername)'" -Properties * -SearchBase $SearchBase | Select-Object EmployeeID,SamAccountName,Department,Office,Division,EmailAddress,Title,employeeNumber,businessCategory,@{N='Manager';E={(Get-ADUser $_.Manager).sAMAccountName}}