### Office 365 Ribbon Customizations - 07/07/2023
$CustomUIFiles = '.\*UI*'
$listOfNames = Get-ChildItem C:\Users -Exclude Public |Select-Object -ExpandProperty Name 
foreach ($User in $listOfNames)
{
    Copy-Item -Path $CustomUIFiles -Destination C:\Users\$User\appdata\Local\Microsoft\Office -Force -Verbose
}
New-Item -Path HKCU:\Software\Intune
New-ItemProperty -Path HKCU:\Software\Intune -Name Remediation_OfficeRibbon2023 -Type String -Value 07112023 -Force -Verbose