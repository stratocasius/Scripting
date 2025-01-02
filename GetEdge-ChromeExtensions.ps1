# Get Edge Extensions
$edgeExtensionsPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Extensions"
if (Test-Path $edgeExtensionsPath) {
    Get-ChildItem -Path $edgeExtensionsPath -Directory | ForEach-Object {
        $manifestPath = Join-Path -Path $_.FullName -ChildPath "manifest.json"
        if (Test-Path $manifestPath) {
            $manifestContent = Get-Content $manifestPath -Raw | ConvertFrom-Json
            [PSCustomObject]@{
                Name    = $manifestContent.name
                Version = $manifestContent.version
                ID      = $_.Name
            }
        }
    } Write-Output "Edge Extensions Found: $edgeExtensionsPath" | Format-Table -AutoSize
} else {
    Write-Output "No Edge extensions found or Edge is not installed."
}

# Get Chrome Extensions
$chromeExtensionsPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Extensions"
if (Test-Path $chromeExtensionsPath) {
    Write-Output "Chrome Extensions Found:"
    Get-ChildItem -Path $chromeExtensionsPath -Directory | ForEach-Object {
        $manifestPath = Join-Path -Path $_.FullName -ChildPath "manifest.json"
        if (Test-Path $manifestPath) {
            $manifestContent = Get-Content $manifestPath -Raw | ConvertFrom-Json
            [PSCustomObject]@{
                Name    = $manifestContent.name
                Version = $manifestContent.version
                ID      = $_.Name
            }
        }
    } | Format-Table -AutoSize
} else {
    Write-Output "No Chrome extensions found or Chrome is not installed."
}
