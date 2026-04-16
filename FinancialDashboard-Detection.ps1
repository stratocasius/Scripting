#########################################
### Financial Dashboard shortcut Detetction
#########################################
# Define the shortcut path
$shortcutPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "FinancialDashboard.url")

# Check if the shortcut exists
if (Test-Path $shortcutPath) {
    Write-Output "Financial Dashboard shortcut exists."
    exit 0
} else {
    Write-Output "No Financial Dashboard shortcut found on $env:USERNAME's desktop."
    exit 1
}
