try {
    # Check if Global Protect is actively connected to a NIC card
    $anyConnectNics = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like '*PANGP*' }
    
    if ($anyConnectNics.Status -eq "Up") {
        Write-Host "Global Protect is connected on"$anyConnectNics.MacAddress with $anyConnectNics.LinkSpeed on $env:COMPUTERNAME""
    }
    else {
        Write-Host "Global Protect is not connected and $env:COMPUTERNAME is connected using $anyConnectNics.InterfaceDescription"
    }
    
}
finally {
    <#Do this after the try block regardless of whether an exception occurred or not#>
}
