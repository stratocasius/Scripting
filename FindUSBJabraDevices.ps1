### Find USB - Jabra devices
# List of remote computer names
$remoteComputers = @("LT4088")

# Loop through each remote computer
foreach ($computer in $remoteComputers) {
    Write-Host "Searching for Jabra headset on $computer..."

    try {
        # Establish a remote PowerShell session
        $session = New-PSSession -ComputerName $computer

        # Run the command to find Jabra headsets
        $jabraDevices = Invoke-Command -Session $session -ScriptBlock {
            Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' -and $_.FriendlyName -like "*Jabra*" }
        }

        # Check if Jabra headset is present
        if ($jabraDevices) {
            Write-Host "Jabra headset is installed on $computer."
            foreach ($device in $jabraDevices) {
                Write-Host "Device Friendly Name: $($device.FriendlyName)"
                Write-Host "Device Instance ID: $($device.InstanceId)"
                Write-Host "---"
            }
        } else {
            Write-Host "Jabra headset is not installed on $computer."
        }
    }
    catch {
        Write-Host "Failed to query devices on $computer. Error: $_"
    }
    finally {
        # Close the remote PowerShell session
        Remove-PSSession -Session $session
    }
}
