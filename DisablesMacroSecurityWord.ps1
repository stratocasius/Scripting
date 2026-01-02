### Disables Macro Security in Word - 07/01/2025
$regPath = "HKCU:\Software\Microsoft\Office\16.0\Word\Security"

# Ensure the key exists
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Disable macro blocking for untrusted files
Set-ItemProperty -Path $regPath -Name "BlockContentExecutionFromInternet" -Value 0 -Type DWord

Write-Output "Macro blocking for untrusted sources disabled in Word."