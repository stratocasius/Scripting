$Status = (Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "Name like 'Windows%'" | where PartialProductKey).licensestatus
If ($Status -ne 1) 
{slmgr.vbs /ipk YKXMC-4NR2F-8R9GR-HC7YV-QPFCF
New-Item -Path "C:\Windows\Temp\WindowsActivated.txt" -Force
$Today = Get-Date
Set-Content -Path "C:\Windows\Temp\WindowsActivated.txt" -Value "Windows 10 Enterprise activated on $Today"
}
else{ 
    {Write-Host "Windows is already activated"}
}