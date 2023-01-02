### Litera Suite Updated MDXT File for 11/23/22
### Litera Microsystems.Data.Enterprise.mdxt to C:\Program Files\Microsystems\Modules folder
Copy-Item -path Microsystems.Data.Enterprise.mdxt -Destination "C:\Program Files\Microsystems\Modules\" -force -verbose
### Litera Microsystems.Data.Enterprise.mdxt to each User\Appdata\Microsystems\Modules folder
$Source = 'Microsystems.Data.Enterprise.mdxt'
$listOfNames = Get-ChildItem C:\Users -Exclude Public |Select-Object -ExpandProperty Name 
foreach ($User in $listOfNames)
{
    New-Item -ItemType Directory -Path C:\Users\$User\appdata\Local\Microsystems\Modules -Force -Verbose
    Copy-Item -Path $Source -Destination C:\Users\$User\appdata\Local\Microsystems\Modules -Force -Verbose
}