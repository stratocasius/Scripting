# Specify the registry key path you want to search
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{D6886603-9D2F-4EB2-B667-1971041FA96B}"

# Define the name of the registry item you want to find
$registryItemName = "LogonCredsAvailable"

# Recursively search for the specified registry item and output its value
Get-ChildItem -Path $registryPath -Recurse | ForEach-Object {
    $key = $_
    $value = Get-ItemProperty -Path $key.PSPath -Name $registryItemName -ErrorAction SilentlyContinue
    if ($value -ne $null) {
        Write-Host "Value of '$registryItemName': $($value.$registryItemName)"
    }
}
