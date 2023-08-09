# Set the path to the custom ribbon XML file
Copy-Item .\
$customRibbonXmlPath = "C:\Path\To\CustomRibbon.xml"

# Check if Office applications are installed
$officeApplications = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'Microsoft Office%'" | Select-Object -ExpandProperty Name

# Loop through the installed Office applications
foreach ($application in $officeApplications) {
    try {
        # Load the Office application's assembly
        $assemblyName = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Office.Interop.$application")

        # Create an instance of the Office application
        $officeApp = New-Object -ComObject "Microsoft.Office.Interop.$application"

        # Get the custom UI XML part for the application
        $customUIPart = $officeApp.CustomUIs.Add("CustomRibbon", $null)

        # Load the custom ribbon XML file
        $customUIPart.LoadXML((Get-Content -Path $customRibbonXmlPath -Raw))

        # Save the changes to the custom ribbon
        $customUIPart.Save()

        # Clean up the COM objects
        $customUIPart = $null
        $officeApp.Quit()
        $officeApp = $null
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()

        Write-Host "Custom ribbon deployed for $application"
    }
    catch {
        Write-Host "Failed to deploy custom ribbon for $application: $_"
    }
}
