#############################################################################
# Check if Global Protect is actively connected to a NIC card
$GPConnectNics = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like '*PANGP*' }

# Check if any Global Protect NICs are found and if they are active
if ($null -ne $GPConnectNics -and $GPConnectNics.Status -eq "Up") {
    # Global Protect is connected
    Write-Host "Global Protect is connected on"$GPConnectNics.MacAddress with $GPConnectNics.LinkSpeed on $env:COMPUTERNAME""
    exit 0  # Exit with success code
} else {
    Write-Host "Global Protect is not connected and "$env:COMPUTERNAME is connected using $GPConnectNics.InterfaceDescription""
    exit 1  # Exit with failure code
}