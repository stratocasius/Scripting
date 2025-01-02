# Define the registry path and value name
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\"
$valueName = "Value"
$desiredValue = "Allow"

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path "C:\Windows\Temp\LocationSvcAllow-Remediation.log" -Value $logMessage
}

# Check if the registry key exists
if (Test-Path -Path $regPath) {
    # Get the current value of the registry entry
    $currentValue = (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName
    
    if ($currentValue -ne $desiredValue) {
        try {
            # Set the registry value to "Allow"
            Set-ItemProperty -Path $regPath -Name $valueName -Value $desiredValue
            Log-Message "Successfully set $regPath\$valueName to $desiredValue"
            Write-Output "Value is set to Allow"
            #Exit 1
        } catch {
            Write-Output "Failed to set value to Allow: Error: $_"
            Log-Message "Failed to set $regPath\$valueName to $desiredValue. Error: $_"
            #Exit 1
        }
    } else {
        Log-Message "$regPath\$valueName is already set to $desiredValue"
        Write-Output "Value already set to Allow"
     #   Exit 0
    }
} else {
    Write-Output "Reg path $regPath doesnt exist."
    Log-Message "Registry path $regPath does not exist"
    #Exit 1
}
