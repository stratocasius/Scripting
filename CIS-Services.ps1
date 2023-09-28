# Define the service names to check
$servicesToCheck = @("SSDPSRV", "icssvc", "WMPNetworkSvc", "upnphost", "SharedAccess", "RpcLocator")

# Create an empty array to store the services found and their status
$servicesFound = @()

# Iterate over each service and check if they exist and their start type
foreach ($serviceName in $servicesToCheck) {
    # Try to get the service by name
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

    # Check if the service was found
    if ($service) {
        # Fetch the start type using Get-WmiObject
        $startType = (Get-WmiObject Win32_Service | Where-Object { $_.Name -eq $serviceName }).StartMode
        $servicesFound += "$serviceName - $startType"
    }
}

# Flag to determine if all are disabled
$allDisabled = $true

# Create the output string
$outputString = ($servicesFound -join ', ')

# Check if all services are disabled
foreach ($service in $servicesFound) {
    if (-not ($service -like '*- Disabled')) {
        $allDisabled = $false
        break
    }
}

# Write the output on a single line
Write-Output $outputString

# Exit with the appropriate code
if ($allDisabled) {
    exit 0
} else {
    exit 1
}
