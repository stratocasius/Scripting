######################################################################################################################
### JL PowerPoint templates 01/02/23
### Establishes PersonalTemplate Registry String for PPT template under File-New and copies the .potx to C:\jltools\JLtemplates
######################################################################################################################
New-Item -type Directory -path "C:\jltools\JLtemplates" -Force -Verbose -ErrorAction SilentlyContinue
Remove-item -Path C:\jltools\JLtemplates\*.potx -Recurse -Force -Verbose -ErrorAction SilentlyContinue
Copy-Item -Path .\JL_PPT_Template_20231Q.potx -Destination "C:\jltools\JLTemplates" -Force -Verbose -ErrorAction SilentlyContinue
Set-ItemProperty -path HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options -Name PersonalTemplates -Value "C:\jltools\JLTemplates" -Force -Verbose -ErrorAction SilentlyContinue
New-Item -Path "C:\Windows\Temp\PowerPointTemplate2023-INSTALL.txt" -Force -Verbose -ErrorAction SilentlyContinue
$Today = Get-Date
Set-Content -Path "C:\Windows\Temp\PowerPointTemplate2023-INSTALL.txt" -Value "JL's 2023 PowerPoint template named JL_PPT_Template_20231Q.potx was applied on $Today"