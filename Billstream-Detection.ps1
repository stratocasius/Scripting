#########################################
### Billstream desktop shortcut Detetction
#########################################
# Define the shortcut path
$shortcutPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "Billstream.url")

# Check if the shortcut exists
if (Test-Path $shortcutPath) {
    Write-Output "Billstream desktop shortcut exists."
    exit 0
} else {
    Write-Output "No Billstream shortcut found on $env:USERNAME's desktop."
    exit 1
}