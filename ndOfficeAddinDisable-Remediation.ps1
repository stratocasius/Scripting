# NetDocuments Add-in LoadBehavior Remediation (with SID + Username logging)

$ErrorActionPreference = 'Stop'

$logDir  = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$logPath = Join-Path $logDir "NetDocs-Addin-LoadBehavior-Remediation.log"

function Write-CMTraceLog {
    param(
        [string]$Message,
        [int]$Type = 1
    )
    $time = (Get-Date).ToString("HH:mm:ss.fff") + "+000"
    $date = (Get-Date).ToString("MM-dd-yyyy")
    $line = "<![LOG[$Message]LOG]!><time=""$time"" date=""$date"" component=""Remediation"" context="""" type=""$Type"" thread=""$PID"" file=""Remediation.ps1"">"
    Add-Content -Path $logPath -Value $line -Encoding UTF8
}

function Get-InteractiveUserSid {
    try {
        $explorer = Get-Process explorer | Select-Object -First 1
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$($explorer.Id)"
        ($proc | Invoke-CimMethod -MethodName GetOwnerSid).Sid
    } catch { $null }
}

function Resolve-UserNameFromSid {
    param($sid)

    try {
        $obj = New-Object System.Security.Principal.SecurityIdentifier($sid)
        $name = $obj.Translate([System.Security.Principal.NTAccount]).Value
        if ($name) { return $name }
    } catch {}

    try {
        $envPath = "Registry::HKEY_USERS\$sid\Environment"
        if (Test-Path $envPath) {
            $env = Get-ItemProperty $envPath
            if ($env.USERNAME) { return $env.USERNAME }
            if ($env.USERPROFILE) { return Split-Path $env.USERPROFILE -Leaf }
        }
    } catch {}

    return $sid
}

function Ensure-Key {
    param($path)
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
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
    "Software\Microsoft\Office\PowerPoint\Addins\NetDocuments.Client.PowerPointAddIn",
    "Software\Microsoft\Office\Outlook\Addins\NetDocuments.ndMail.OutlookAddIn",
    "Software\Microsoft\Office\Outlook\Addins\MailSync"
)

$changes = @()

foreach ($key in $targets) {

    $path = "Registry::HKEY_USERS\$sid\$key"
    Ensure-Key $path

    $current = (Get-ItemProperty $path -Name LoadBehavior -ErrorAction SilentlyContinue).LoadBehavior

    if ($current -ne 0) {
        New-ItemProperty -Path $path -Name LoadBehavior -PropertyType DWord -Value 0 -Force | Out-Null
        Write-CMTraceLog "FIX | $key | Set LoadBehavior=0"
        $changes += $key
    }
    else {
        Write-CMTraceLog "PASS | $key | Already 0"
    }
}

# ---------------------------
# Kill ndOffice.exe if running
# ---------------------------
try {
    $proc = Get-Process ndOffice -ErrorAction SilentlyContinue
    if ($proc) {
        Stop-Process -Name ndOffice -Force -ErrorAction SilentlyContinue
        Write-CMTraceLog "ACTION | ndOffice.exe stopped"
        $processAction = "Stopped"
    }
    else {
        $processAction = "NotRunning"
    }
}
catch {
    Write-CMTraceLog "ERROR | Failed to stop ndOffice.exe: $($_.Exception.Message)" 3
    $processAction = "Error"
}
# ---------------------------
# Kill NetDocuments.ndMail.Application.exe if running
# ---------------------------
try {
    $proc = Get-Process ndOffice -ErrorAction SilentlyContinue
    if ($proc) {
        Stop-Process -Name NetDocuments.ndMail.Application.exe -Force -ErrorAction SilentlyContinue
        Write-CMTraceLog "ACTION | NetDocuments.ndMail.Application.exe stopped"
        $processAction = "Stopped"
    }
    else {
        $processAction = "NotRunning"
    }
}
catch {
    Write-CMTraceLog "ERROR | Failed to stop NetDocuments.ndMail.Application.exe $($_.Exception.Message)" 3
    $processAction = "Error"
}


# ---------------------------
# Output summary (short + clean)
# ---------------------------
if ($changes.Count -gt 0) {
    Write-Output ("Updated|User={0}|Keys={1}|ndOffice={2}" -f $user, ($changes -join ','), $processAction)
}
else {
    Write-Output ("NoChange|User={0}|ndOffice={1}" -f $user, $processAction)
}

Write-CMTraceLog "Complete"
exit 0