# Path to the Office document
$filePath = "C:\users\seditaj\t3.dotm"

# Create a Shell.Application object
$shell = New-Object -ComObject Shell.Application

# Get the folder object
$folder = $shell.Namespace((Get-Item $filePath).DirectoryName)

# Get the file object
$file = $folder.ParseName((Get-Item $filePath).Name)

# Loop through property indices 0 through 99
for ($index = 0; $index -le 9999; $index++) {
    # Get the property name and value
    $propertyName = $folder.GetDetailsOf($folder.Items, $index)
    $propertyValue = $folder.GetDetailsOf($file, $index)

    # Output the index, property name, and value
    Write-Output "Index: $index, Property: $propertyName, Value: $propertyValue"
}

# Cleanup COM objects
$null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell)
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
