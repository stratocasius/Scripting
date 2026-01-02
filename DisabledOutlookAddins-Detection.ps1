$officeAddinsRegistryPath = "HKCU:\Software\Microsoft\Office\Outlook\Addins"  # Change this path to the appropriate Office application

 # Get a list of all subkeys (add-ins) under the specified registry path

$addins = Get-ChildItem -Path $officeAddinsRegistryPath

 # Iterate through each add-in and check if it's disabled

foreach ($addin in $addins) {

    $addinName = $addin.PSChildName

    $isEnabled = (Get-ItemProperty -Path "$officeAddinsRegistryPath\$addinName").IsEnabled

 

    if (-Not $isEnabled) {

        Write-Host "Disabled Add-In: $addinName"

    }

}