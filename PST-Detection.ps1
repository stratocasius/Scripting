##################################
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
        Write-Output "Found value name '$targetValueName' in key: $($key.PSPath)"
        Exit 0
    }
}