# Script require Import-Excel Module which can be installed by running <Install-Module ImportExcel> For Info = (https://github.com/dfinke/ImportExcel) #

# Set Path where your Census is located.
$users = Import-Excel "C:\Users\ebarksdale\Downloads\Census_2020-02-28.xlsx"

# Changelog appended with today's date.
#$date = ((Get-Date).ToString('yyyy-MM-dd'))
#$logFile = "C:\Scripts\HRIS_CensusCSV_to_AD\Changelogs" + " " + $date +  ".log"

# Start of logging.
#Start-Transcript -Path $logFile -Force

# Set AD OU search base.
$SearchBase = "OU=Departments,OU=Datto,DC=datto,DC=lan"

# Start of script.
Write-Output "Starting import script"


# Loop through $users to find differences and apply any changes that need to be made.
foreach ($user in $users)
{
    # Set $ADUsers to pull from AD based on each users samaccountname.
    $adUsers = Get-ADUser -Filter "SamAccountName -eq '$($user.EmployeeUsername)'" -Properties * -SearchBase $SearchBase | Select-Object EmployeeID,SamAccountName,Department,Office,Division,EmailAddress,Title,employeeNumber,businessCategory,@{N='Manager';E={(Get-ADUser $_.Manager).sAMAccountName}}
    
    # Defining the excel file columns as an array.
    $array = @( @{Attribute="Username:"; Value="$($user.EmployeeUsername)"},
                @{Attribute="Department:"; Value="$($user.Department)"},
                @{Attribute="Title:"; Value="$($user.Title)"},
                @{Attribute="Manager:"; Value="$($user.ManagerUsername)"},
                @{Attribute="Team:"; Value="$($user.Team)"},
                @{Attribute="Office:"; Value="$($user.Location)"},
                @{Attribute="Subsidiary:"; Value="$($user.Subsidiary)"},
                @{Attribute="Employee ID:"; Value="$($user.empid)"},
                @{Attribute="Badge Number:"; Value="$($user.BadgeNumber)"},
                @{Attribute="Exec Group:"; Value="$($user.ExecGroup)"}) | ForEach-Object {[PSCustomObject]$_} | Format-Table Attribute,Value -Autosize 
        
        # Comparing each AD attribute to each attribute in the excel array.
        if ((@($adUsers.EmployeeID) -ne @($user.empid)) -or
            (@($null -eq $adUsers.EmployeeID)) -or
            (@($adUsers.employeeNumber -ne $user.BadgeNumber)) -or
            (@($null -eq $adUsers.employeeNumber)) -or 
            (@($adUsers.SamAccountName) -ne @($user.EmployeeUsername)) -or
            (@($null -eq $adUsers.SamAccountName)) -or 
            (@($adUsers.Department) -ne @($user.Department)) -or
            (@($null -eq $adUsers.Department)) -or 
            (@($adUsers.Office) -ne @($user.Location)) -or
            (@($null -eq $adUsers.Office)) -or 
            (@($adUsers.Division) -ne @($user.Team)) -or
            (@($null -eq $adUsers.Division  )) -or 
            (@($adUsers.EmailAddress) -ne @($user.Email)) -or
            (@($null -eq $adUsers.EmailAddress  )) -or 
            (@($adUsers.Title) -ne @($user.Title)) -or
            (@($null -eq $adUsers.Title)) -or 
            (@($adUsers.businessCategory) -ne @($user.ExecGroup)) -or
            (@($null -eq $adUsers.businessCategory)) -or 
            (@($adUsers.Manager) -ne @($user.ManagerUsername)) -or
            (@($null -eq $adUsers.Manager))) 
        {
            # Set the users attributes based on the census.
            Get-ADUser -Filter "SamAccountName -eq '$($user.EmployeeUsername)'" -Properties * -SearchBase $SearchBase | Set-ADUser -Title $($user.Title) -Department $($user.Department) -Manager $($user.ManagerUsername) -Division $($user.Team) -Office $($user.Location) -Company $($user.Subsidiary) -employeeID $($user.empid) -employeeNumber $($user.BadgeNumber) -Replace @{businessCategory=$($user.ExecGroup)} -WhatIf 
                        
            # Output what was changed to the console.
            Write-Host $user.EmployeeUsername is being set to:

            $array
        }
}

# Self Explanatory.
Write-Output "Census updated successfully." -Verbose
<#
# End of Logging.
Stop-Transcript 

# Email variable definitions.
$smtpServer = "mail.datto.lan"
$smtpFrom = "Census <Census_Update@datto.com>"
$smtpTo = 'Ethan Barksdale <ebarksdale@datto.com>', 'Matt Jurczyk <mjurczyk@datto.com>', 'Mario Paniagua <mpaniagua@datto.com>', 'Christine Slade <cslade@datto.com>','Marianne Larsh <mlarsh@datto.com>','Mike Ceonzo <mceonzo@datto.com>'
$smtpSubject = "Census Update Complete"
$smtpBody = "Census update has completed successfully."

# Send Email to all interested parties.
Send-MailMessage -SmtpServer $smtpServer -From $smtpFrom -To $smtpTo -Subject $smtpSubject -Body $smtpBody -Priority High 

# End of script.
Write-Output "Email has been sent successfully, script run complete."
#>
