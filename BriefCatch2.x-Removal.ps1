# Define the Product ID (Product Code) of the application you want to uninstall
$productID = "{F0DD92DD-B41E-487B-8126-EBA4F7494055}"

# Attempt to uninstall the application using msiexec
try {
    Start-Process -Wait -FilePath "msiexec.exe" -ArgumentList "/x $productID /qn /l C:\Windows\Temp\BriefCatch2.5.60-Removal.log"
    Write-Host "Successfully uninstalled application with Product ID $productID"
} catch {
    Write-Host "Error uninstalling application with Product ID $productID $($_.Exception.Message)"
}
