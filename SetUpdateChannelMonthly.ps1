# Set the path to the OfficeC2RClient.exe executable
$officeC2RClientPath = "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"

# Define the registry key path and value name
$keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate\"
$valueName = "updatebranch"

# Define the new value data and log file path as variables
$newValueData = "MonthlyEnterprise"
$logFilePath = "C:\windows\temp\office-update-channel-change.log"

# Check if the registry key and value exist
if (Test-Path $keyPath) {
    $value = Get-ItemPropertyValue -Path $keyPath -Name $valueName -ErrorAction SilentlyContinue
    if ($value) {
        # Get the current value data of the registry value
        $oldValue = $value

        # Log the old value data to a file
        Add-Content -Path $logFilePath -Value "Old value of $valueName : $oldValue"
        Write-Host "New value of $valueName : $newValueData"

        # Set the new value data of the registry value
        Set-ItemProperty -Path $keyPath -Name $valueName -Value $newValueData -Force

        # Log the new value data to the file
        Add-Content -Path $logFilePath -Value "New value of $valueName : $newValueData"
        Write-host "New value of $valueName : $newValueData"
    } else {
        # Log a message if the registry value does not exist
        Add-Content -Path $logFilePath -Value "Registry value $valueName not found."
        Write-Host "Registry value $valueName not found."
    }
} else {
    # Log a message if the registry key does not exist
    Add-Content -Path $logFilePath -Value "Registry key $keyPath not found."
    Write-host "Registry key $keyPath not found."
}
# Run OfficeC2RClient.exe to update Office 365. Un-comment these lines if you want the update to kick off silently. Office will close and not give the user the chance to save work
<# 

& $officeC2RClientPath /update user updatepromptuser=false forceappshutdown=true displaylevel=false

Add-Content -Path $logFilePath -Value "Office 365 updated Started"
Write-Host "Office 365 updated Started" 
#>
