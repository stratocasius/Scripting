#########################################
### Billstream desktop shortcut Detetction
#########################################
# Define the shortcut path
$shortcutPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "Billstream.url")

# Check if the shortcut exists
if (Test-Path $shortcutPath) {
    Write-Output "Billstream desktop shortcut exists."
    #exit 0
} else {
    Write-Output "No Billstream shortcut found on $env:USERNAME's desktop."
    #exit 1
}



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

Write-Output "Billstream shortcut created on $env:USERNAME's desktop at $(Get-Date)."
