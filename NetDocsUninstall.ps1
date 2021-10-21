$app = Get-WmiObject -Class Win32_Product | Where-Object { 
    $_.Name -match "Netdocuments Document Activation" 
}
$app.Uninstall()