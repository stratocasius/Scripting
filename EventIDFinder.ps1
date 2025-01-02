$events = Get-WinEvent -LogName System | Where-Object { $_.ID -eq 506 }

if ($events) {
    foreach ($event in $events) {
        $time = $event.TimeCreated
        Write-Host "Event ID $($event.ID) - System went to sleep at $time"
    }
} else {
    Write-Host "No sleep events found in the System Event Log."
}

#### Windows Hello PIN Finder()
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$propertyName = "AllowDomainPINLogon"

# Get the current value of the registry setting
$currentValue = (Get-ItemProperty -Path $registryPath -Name $propertyName).$propertyName
Write-Output "Registry value '$currentvalue'"