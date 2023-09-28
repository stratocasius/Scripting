# Define the Product ID (GUID) of the application you want to uninstall
$productId = "{3C21C9CB-853E-4448-A81B-184BAA5854C9}"

# Query Win32_Product class to get the application
$application = Get-WmiObject -Class Win32_Product | Where-Object { $_.IdentifyingNumber -eq $productId }

# Check if the application was found
if ($application -eq $null) {
    Write-Host "Application not found with Product ID: $productId"
} else {
    # Uninstall the application
    $uninstallResult = $application.Uninstall()

    # Check the result of the uninstallation
    if ($uninstallResult.ReturnValue -eq 0) {
        Write-Host "Application with Product ID: $productId has been uninstalled successfully."
    } else {
        Write-Host "Failed to uninstall application with Product ID: $productId. Error code: $($uninstallResult.ReturnValue)"
    }
}
