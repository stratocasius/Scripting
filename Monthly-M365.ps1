$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate"
$RegName = "updatebranch"
$DesiredValue = "Monthly"

# Check if the registry path exists
if (-not (Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Check if the value exists
$currentValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $RegName -ErrorAction SilentlyContinue

# If the value doesn't exist or isn't 'Monthly', set it
if ($null -eq $currentValue -or $currentValue -ne $DesiredValue) {
    Set-ItemProperty -Path $RegPath -Name $RegName -Value $DesiredValue
    Write-Output "Updatebranch set to '$DesiredValue'"
} else {
    Write-Output "Updatebranch is already set to '$DesiredValue'. No changes made."
}