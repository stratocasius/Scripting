# Detection script
try {
    $service = Get-Service -Name PanGPS -ErrorAction Stop
    if ($service.Status -ne 'Running') {
        Write-Output "PanGPS not running, Starting"
        exit 1
    } else {
        Write-Output "PanGPS Running"
        exit 0
    }
} catch {
    Write-Output "PanGPS service not found"
    exit 0
}


### Stop service
# Remediation script
try {
    $service = Get-Service -Name PanGPS -ErrorAction Stop
    if ($service.Status -ne 'Running') {
        Start-Service -Name PanGPS
        Write-Output "PanGPS service started successfully"
    } else {
        Write-Output "PanGPS is already running, no action needed"
    }
} catch {
    Write-Output "Error starting PanGPS service: $_"
}