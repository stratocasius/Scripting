###Detection Script###
$installedApps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, UninstallString
$installedApps += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, UninstallString

###Looking for Firefox and Chrome specifically###
$firefox = '*Firefox*'
$firefox = $installedApps | Where-Object{ $_.DisplayName -ne $null } | Where-Object {$_.DisplayName -like $firefox } 
$chrome = '*Chrome*'
$chrome = $installedApps | Where-Object{ $_.DisplayName -ne $null } | Where-Object {$_.DisplayName -like $chrome}

###If either are present, return false###
if(($null -ne $firefox) -or ($null -ne $chrome)){
    $false
}else{
    $true
}