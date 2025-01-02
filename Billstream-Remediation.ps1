

#########################################
### Billstream desktop shortcut Remediation
#########################################
# Define the URL and shortcut name
$url = "https://jacksonlewis.billstream.prod.intapp.com/"
$shortcutName = "Billstream"

# Define the path to the user's desktop
$desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "$shortcutName.url")

# Create the shortcut
$shortcutContent = "[InternetShortcut]`nURL=$url`n"
Set-Content -Path $desktopPath -Value $shortcutContent -Force
Exit 0
Write-Output "Billstream shortcut created on $env:USERNAME's desktop at $(Get-Date)."