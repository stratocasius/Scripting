$path = "C:\programdata\Litera\customize"

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



# Define the source and destination paths
$sourcePath = "\\jacksonlewis.net\Shares\Litera Software\customize"
$destinationPath = "C:\Programdata\Litera\Customize"

# Check if the destination directory exists, if not, create it
if (-Not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath -Force
}

# Copy the contents from the source to the destination
Copy-Item -Path "$sourcePath\*" -Destination $destinationPath -Recurse -Force

# Verify that the files were copied
if (Test-Path -Path "$destinationPath\*") {
    Write-Output "Files were successfully copied to $destinationPath."
} else {
    Write-Output "Failed to copy files to $destinationPath."
}
