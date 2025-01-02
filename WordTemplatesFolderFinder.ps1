$path = "$env:APPDATA\Microsoft\Templates"

if (Test-Path $path) {
    $item = Get-Item $path
    if ($item.PSIsContainer) {
        Write-Output "The path '$path' is a folder."
        Exit 0
    } else {
        if ($item.Extension -eq "") {
            Write-Output "The path '$path' is a flat file with no extension."
            Exit 1
        } else {
            Write-Output "The path '$path' is a file with an extension."
            Exit 1
        }
    }
} else {
    Write-Output "The path '$path' does not exist."
    Exit 1
}
