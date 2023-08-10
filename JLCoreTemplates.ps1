### JL Core Templates - 06/02/2023
$listOfNames = Get-ChildItem C:\Users -Exclude Public |Select-Object -ExpandProperty Name 
foreach ($User in $listOfNames)
{
    Copy-Item -path .\*dotm -Destination "C:\Users\$User\appdata\Roaming\Microsoft\Templates" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }
New-Item -Path HKCU:\Software\Intune
New-ItemProperty -Path HKCU:\Software\Intune -Name Remediation_JLCoreTemplates -Type String -Value 06022023 -Force -Verbose