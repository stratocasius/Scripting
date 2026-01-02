# Define registry path and value
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate"
$ValueName = "updatebranch"

# Try to read the registry value
try {
    $value = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop

    if ($value.$ValueName) {
        Write-Output "updatebranch: $($value.$ValueName)"
        exit 0
    } else {
        Write-Output "'updatebranch' value not set."
        exit 1
    }
}
catch {
    Write-Output "Registry key or 'updatebranch' value not found."
    exit 1
}