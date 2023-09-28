### InterAction for Microsoft Outlook 7.01 Removal(IMO)
### Establish IA Windows Client Product ID
$productId = "{EB61453D-A6D4-429C-A7C7-3BFE15A2D535}"

### Query Win32_Product class to get the application
$application = Get-WmiObject -Class Win32_Product | Where-Object { $_.IdentifyingNumber -eq $productId }
### Check if the application was found
if ($application -eq $null) {
    New-Item -Path "C:\Windows\Temp\IA7-IMO-NotFound.log" -ItemType File
    Set-Content -Path "C:\Windows\Temp\IA7-IMO-NotFound.log" -Value "InterAction for Microsoft Outlook 7.01 was not found to be installed on $env:COMPUTERNAME" -Force
} else {
    # Uninstall the application
    $uninstallResult = $application.Uninstall()

    # Check the result of the uninstallation
    if ($uninstallResult.ReturnValue -eq 0) {
        New-Item -Path "C:\Windows\Temp\IA7-IMO-Removal.log" -ItemType File
        Set-Content -Path "C:\Windows\Temp\IA7-IMO-Removal.log" -Value "InterAction for Microsoft Outlook 7.01 was removed on $Today" -Force
    } else {
        Write-Host "Failed to uninstall application with Product ID: $productId. Error code: $($uninstallResult.ReturnValue)"
    }
}
