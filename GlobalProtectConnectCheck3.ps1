#############################################################################
# Check if Global Protect is actively connected to a NIC card
$GPConnectNics = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like '*PANGP*' }
$ACConnectNics = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like '*Cisco*'}

# Check if any Global Protect NICs are found and if they are active
if ($null -ne $GPConnectNics -and $GPConnectNics.Status -eq "Up") {
    # Global Protect is connected
    Write-Host "Global Protect is connected on"$GPConnectNics.MacAddress with $GPConnectNics.LinkSpeed on $env:COMPUTERNAME""
    exit 0  # Exit with success code
} else{ 
($null -ne $ACConnectNics -and $ACConnectNics.Status -eq "Up") 
        # Global Protect is connected
    Write-Host ""$env:COMPUTERNAME is connected using $ACConnectNics.InterfaceDescription""
    exit 1  # Exit with failure code
}
