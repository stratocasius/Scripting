################################################################################################################
### PST Finder - Looks for and reports location of 001f6700 DWORD in HKCU, indicating a PST is found.
function Find-RegistryDWordName {
    param (
        [string]$SearchRoot,
        [string]$ValueName
    )
        $keys = Get-ChildItem -Path $SearchRoot -Recurse |
            ForEach-Object {
                $valueNames = $_ | Get-ItemProperty | ForEach-Object { $_.PSObject.Properties.Name }
                if ($valueNames -contains $ValueName) {
                    $_
                }
            }
        return $keys
}
# Usage
$targetRoot = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles\Outlook"
$targetValueName = "001f6700"
$result = Find-RegistryDWordName -SearchRoot $targetRoot -ValueName $targetValueName
if ($result) {
    foreach ($key in $result) {


      ### Write-Output "Found value name '$targetValueName' in key: $($key.PSPath)"
      ### Grab hex value, make variable
      # Specify the registry key and value name
$regKey = $key.PSPath
$valueName = "001f6700"

# Get the binary data from the registry
$binaryData = (Get-ItemProperty -Path $regKey -Name $valueName).$valueName

# Convert the binary data to a hexadecimal string
$hexString = $binaryData | ForEach-Object { $_.ToString("X2") }
# Convert byte array to a readable string (assuming text representation)
$readableString = [System.Text.Encoding]::UTF8.GetString($binarydata)

# Original string with spaces
$originalString = $readableString

# Remove spaces between characters
### $noSpacesString = $originalString -replace "'\s'", ''

# Output the result
Write-Output "PST found at $originalString"
Exit 0
    }
}