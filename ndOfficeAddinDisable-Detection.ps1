# NetDocuments Add-in LoadBehavior Detection (with SID + Username logging)

$ErrorActionPreference = 'SilentlyContinue'

$logDir  = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$logPath = Join-Path $logDir "NetDocs-Addin-LoadBehavior-Detection.log"

function Write-CMTraceLog {
    param(
        [string]$Message,
        [int]$Type = 1
    )
    $time = (Get-Date).ToString("HH:mm:ss.fff") + "+000"
    $date = (Get-Date).ToString("MM-dd-yyyy")
    $line = "<![LOG[$Message]LOG]!><time=""$time"" date=""$date"" component=""Detection"" context="""" type=""$Type"" thread=""$PID"" file=""Detection.ps1"">"
    Add-Content -Path $logPath -Value $line -Encoding UTF8
}

function Get-InteractiveUserSid {
    try {
        $explorer = Get-Process explorer -ErrorAction Stop | Select-Object -First 1
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$($explorer.Id)"
        ($proc | Invoke-CimMethod -MethodName GetOwnerSid).Sid
    } catch { $null }
}

function Resolve-UserNameFromSid {
    param($sid)

    # 1. NTAccount
    try {
        $obj = New-Object System.Security.Principal.SecurityIdentifier($sid)
        $name = $obj.Translate([System.Security.Principal.NTAccount]).Value
        if ($name) { return $name }
    } catch {}

    # 2. HKU Environment
    try {
        $envPath = "Registry::HKEY_USERS\$sid\Environment"
        if (Test-Path $envPath) {
            $env = Get-ItemProperty $envPath
            if ($env.USERNAME) { return $env.USERNAME }
            if ($env.USERPROFILE) { return Split-Path $env.USERPROFILE -Leaf }
        }
    } catch {}

    # 3. UserProfile
    try {
        $profile = Get-CimInstance Win32_UserProfile | Where-Object { $_.SID -eq $sid }
        if ($profile.LocalPath) { return Split-Path $profile.LocalPath -Leaf }
    } catch {}

    return $sid
}

$sid = Get-InteractiveUserSid

if (-not $sid) {
    Write-CMTraceLog "No interactive user found"
    exit 0
}

$user = Resolve-UserNameFromSid $sid
Write-CMTraceLog "Start | SID=$sid | User=$user"

$targets = @(
    "Software\Microsoft\Office\Word\Addins\NetDocuments.Client.WordAddIn",
    "Software\Microsoft\Office\Excel\Addins\NetDocuments.Client.ExcelAddIn",
    "Software\Microsoft\Office\Outlook\Addins\NetDocuments.Client.OutlookAddIn",
    "Software\Microsoft\Office\PowerPoint\Addins\NetDocuments.Client.PowerPointAddIn"
    "SOFTWARE\Microsoft\Office\Outlook\Addins\NetDocuments.ndMail.OutlookAddIn"
    "Software\Microsoft\Office\Outlook\Addins\MailSync"
)

foreach ($key in $targets) {
    $path = "Registry::HKEY_USERS\$sid\$key"

    if (-not (Test-Path $path)) {
        Write-CMTraceLog "FAIL | $key | Missing"
        exit 1
    }

    $val = (Get-ItemProperty $path -Name LoadBehavior -ErrorAction SilentlyContinue).LoadBehavior

    if ($val -ne 0) {
        Write-CMTraceLog "FAIL | $key | LoadBehavior=$val"
        exit 1
    }

    Write-CMTraceLog "PASS | $key | LoadBehavior=0"
}

Write-CMTraceLog "Compliant"
exit 0