### Creates and copies file to C:\Users\*\AppData\Local\Microsystems\Modules
$Source = '.\LiteraCustomizations\Microsystems.Data.Enterprise.mdxt'
$Destination = 'C:\users\*\AppData\Local\Microsystems\Modules'
$listOfNames = Get-ChildItem C:\Users |Select-Object -ExpandProperty Name 
foreach ($User in $listOfNames)
{
    New-Item -ItemType Directory -Path C:\Users\$User\appdata\Local\Microsystems\Modules -Force -Verbose
    Copy-Item -Path $Source -Destination C:\Users\$User\appdata\Local\Microsystems\Modules -Force -Verbose
}