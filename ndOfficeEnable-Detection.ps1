### ndOffice Disable - Remediation - Detection Script 02/12/2025
# Define registry paths to check
$RegistryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\NetDocuments.ndMail.OutlookAddIn",
    "HKLM:\SOFTWARE\Microsoft\Office\Word\Addins\NetDocuments.Client.WordAddIn",
    "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\NetDocuments.Client.OutlookAddIn",
    "HKLM:\SOFTWARE\Microsoft\Office\Excel\Addins\NetDocuments.Client.ExcelAddIn",
    "HKLM:\SOFTWARE\Microsoft\Office\PowerPoint\Addins\NetDocuments.Client.PowerPointAddIn"
    "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\MailSync"
)

# Target value
$TargetValueName = "LoadBehavior"
$DesiredValue = 2

# Flag to determine compliance
$Compliant = $true

foreach ($Path in $RegistryPaths) {
    if (Test-Path -Path $Path) {
        $CurrentValue = (Get-ItemProperty -Path $Path -Name $TargetValueName -ErrorAction SilentlyContinue).$TargetValueName
        if ($CurrentValue -ne $DesiredValue) {
            $Compliant = $false
        }
    } else {
        $Compliant = $false
    }
}

if ($Compliant) {
    Write-Output "ndOffice is already Enabled for MS Office"
    exit 0
} else {
    Write-Output "REMEDIATION NEEDED!!! ndOffice is Disabled for MS Office."
    exit 1
}