# Check if Cisco AnyConnect is actively connected to a NIC card
$anyConnectNics = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like '*Cisco AnyConnect*' }

if ($anyConnectNics.Status -eq "Up") {
    Write-Host "True"
}
else {
    Write-Host "False"
}
