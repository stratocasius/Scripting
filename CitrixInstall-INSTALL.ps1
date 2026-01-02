### Citrix Detection Script###
$installedApps = Get-ItemProperty HKLM:\Software\* |  Select-Object DisplayVersion, UninstallString
$installedApps += Get-ItemProperty HKLM:\Software\Wow6432Node\* | Select-Object DisplayVersion, UninstallString

### Looking for Citrix Online Plug-in Version 22.3.6002.6116 
$Citrix = '22.3.6002.6116'
$Citrix = $installedApps | Where-Object{ $_.DisplayVersion -ne $null } | Where-Object {$_.DisplayVersion -like $Citrix } 


###If present, return false###
if(($null -ne $Citrix)){
    $false
}else{
    $true
}