##################################################################################################################################
# Define the base registry path to start the search
$baseRegistryPath = "HKCU:\SOFTWARE\Microsoft\Office\Outlook"  # Change this to your desired base path

# Function to recursively search for DWORD values named "LoadBehavior" with a value of 3 and output their values
function Search-LoadBehavior {
    param (
        [string]$registryPath
    )

    # Get all subkeys under the current registry path
    $subkeys = Get-ChildItem -Path $registryPath

    foreach ($subkey in $subkeys) {
        # Check if the subkey has a "LoadBehavior" DWORD value with a value of 3
        $loadBehaviorValue = (Get-ItemProperty -Path $subkey.PSPath -Name "LoadBehavior" -ErrorAction SilentlyContinue)."LoadBehavior"

        if ($loadBehaviorValue -eq 3) {
            Write-Host "Registry Path: $($subkey.PSPath)"
            Write-Host "LoadBehavior Value: $loadBehaviorValue"
        }

        # Recursively search subkeys
        Search-LoadBehavior -registryPath $subkey.PSPath
    }
}

# Start the search from the base registry path
Search-LoadBehavior -registryPath $baseRegistryPath
