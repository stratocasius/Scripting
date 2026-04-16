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


#########################################
### Financial Dashboard shortcut Remediation
#########################################
# Define the URL and shortcut name
$url = "https://financialdashboard.jacksonlewis.com/"
$shortcutName = "FinancialDashboard"

# Define the path to the user's desktop
$desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "$shortcutName.url")

# Create the shortcut
$shortcutContent = "[InternetShortcut]`nURL=$url`n"
Set-Content -Path $desktopPath -Value $shortcutContent -Force

Write-Output "Financial Dashboard shortcut created on $env:USERNAME's desktop at $(Get-Date)."
