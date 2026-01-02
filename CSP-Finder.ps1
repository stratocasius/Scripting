# Define export path
$ExportPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\CSPs.csv"

# Expanded list of relevant event IDs for CSP policy success and failure
$EventIDs = @(201, 404, 813, 814, 4096, 4097, 4098, 4099)

# Pull and filter the events
$events = Get-WinEvent -LogName "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin" |
    Where-Object { $EventIDs -contains $_.Id } |
    Select-Object TimeCreated, Id, LevelDisplayName, Message

# Export to CSV
$events | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8

Write-Output "Export complete. CSP events written to $ExportPath"