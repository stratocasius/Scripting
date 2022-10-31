 $user="dossr"
 Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -match $user} | Remove-Item