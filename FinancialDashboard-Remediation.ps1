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