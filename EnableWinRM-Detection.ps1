### Enable WinRM locally - Detection
# Detection Script
$service = Get-Service -Name WinRM -ErrorAction SilentlyContinue

if ($service) {
    if ($service.StartType -eq 'Automatic') {
        Write-Output "WinRM service is set to start automatically."
        exit 0
    } else {
        Write-Output "WinRM service is NOT set to start automatically."
        exit 1
    }
} else {
    Write-Output "WinRM service is not found."
    exit 1
}
