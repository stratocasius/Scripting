# NetDocuments Add-in LoadBehavior Remediation
# Ensures LoadBehavior = 0 for Word, Excel, Outlook, PowerPoint add-ins
# Intended for Intune Proactive Remediations running as SYSTEM

$ErrorActionPreference = 'Stop'

function Get-InteractiveUserSid {
    try {
        $explorer = Get-Process explorer -ErrorAction Stop | Select-Object -First 1
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$($explorer.Id)" -ErrorAction Stop
        ($proc | Invoke-CimMethod -MethodName GetOwnerSid -ErrorAction Stop).Sid
    } catch {
        $null
    }
}

function Ensure-RegistryKey {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

function Set-LoadBehaviorZero {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Sid,

        [Parameter(Mandatory = $true)]
        [string]$SubKey
    )

    $path = "Registry::HKEY_USERS\$Sid\$SubKey"
    Ensure-RegistryKey -Path $path

    $currentValue = $null
    try {
        $currentValue = (Get-ItemProperty -Path $path -Name 'LoadBehavior' -ErrorAction SilentlyContinue).LoadBehavior
    } catch {
        $currentValue = $null
    }

    if ($currentValue -ne 0) {
        New-ItemProperty -Path $path -Name 'LoadBehavior' -PropertyType DWord -Value 0 -Force | Out-Null
        Write-Output "Remediated|$SubKey|LoadBehavior=0"
    } else {
        Write-Output "Compliant|$SubKey|LoadBehavior=0"
    }
}

try {
    $sid = Get-InteractiveUserSid
    if (-not $sid) {
        Write-Output "NoInteractiveUser|NotApplicable"
        exit 0
    }

    $targets = @(
        'Software\Microsoft\Office\Word\Addins\NetDocuments.Client.WordAddIn',
        'Software\Microsoft\Office\Excel\Addins\NetDocuments.Client.ExcelAddIn',
        'Software\Microsoft\Office\Outlook\Addins\NetDocuments.Client.OutlookAddIn',
        'Software\Microsoft\Office\PowerPoint\Addins\NetDocuments.Client.PowerPointAddIn'
    )

    foreach ($subKey in $targets) {
        Set-LoadBehaviorZero -Sid $sid -SubKey $subKey
    }

    exit 0
}
catch {
    Write-Output "Failed|$($_.Exception.Message)"
    exit 1
}