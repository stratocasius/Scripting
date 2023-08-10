### Updated Core Templates Removal - 05/23/2023
### Updated Core Templates - 05/23/2023
$listOfNames = Get-ChildItem C:\Users -Exclude Public |Select-Object -ExpandProperty Name 
foreach ($User in $listOfNames)
{
    Remove-Item -path "C:\Users\$User\appdata\Roaming\Microsoft\Templates\JLLetter.dotm" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item -path "C:\Users\$User\appdata\Roaming\Microsoft\Templates\JLLetter2.dotm" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item -path "C:\Users\$User\appdata\Roaming\Microsoft\Templates\JLMemo.dotm" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item -path "C:\Users\$User\appdata\Roaming\Microsoft\Templates\JLFax.dotm" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }
Set-Location -Path HKCU:\Software\Intune  
Remove-ItemProperty -Path HKCU:\Software\Intune -Name Remediation_JLUpdatedCoreTemplates -Force -Verbose 