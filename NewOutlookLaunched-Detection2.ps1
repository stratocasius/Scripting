<#
Intune Remediation - Detection Script (PS5.1 compatible)
Detect if "new Outlook" (olk.exe) has been launched within the last 90 days.

Evidence sources (last 90 days):
- Microsoft-Windows-TWinUI/Operational : IDs 304, 305, 306 (packaged app activation)
- Microsoft-Windows-AppModel-Runtime/Admin : activation traces
- Optional: C:\Windows\Prefetch\OLK.EXE-*.pf timestamp (fallback; may not exist)

Exit 1 = Found (trigger remediation)
Exit 0 = Not found
#>

# ---------------- Settings ----------------
$LookbackDays = 90
$StartTime    = (Get-Date).AddDays(-[int]$LookbackDays)

$TargetPackageHint = 'Microsoft.OutlookForWindows'
$TargetExeHint     = 'olk.exe'

# Logging
$LogRoot = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\Logs'
$LogPath = Join-Path $LogRoot 'OutlookNew-LaunchDetection.log'
if (-not (Test-Path $LogRoot)) { New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null }

# Simple rotation if log > 1 MB
try {
    if (Test-Path $LogPath) {
        if ((Get-Item $LogPath).Length -gt 1MB) {
            $archive = Join-Path $LogRoot ('OutlookNew-LaunchDetection_{0:yyyyMMdd_HHmmss}.log' -f (Get-Date))
            Move-Item -Path $LogPath -Destination $archive -Force
        }
    }
} catch {}

function Write-Log {
    param([string]$Message)
    $line = "[{0:yyyy-MM-dd HH:mm:ss}] {1}" -f (Get-Date), $Message
    $line | Out-File -FilePath $LogPath -Append -Encoding UTF8
    Write-Output $line
}

"==== Detection start {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date) | Out-File -FilePath $LogPath -Append -Encoding UTF8
Write-Log ("Lookback window: last {0} day(s) since {1}" -f $LookbackDays, $StartTime.ToString('yyyy-MM-dd HH:mm:ss'))
Write-Log ("Searching for launches of new Outlook (PackageHint='{0}', ExeHint='{1}')." -f $TargetPackageHint, $TargetExeHint)

$matches = @()

# Source 1: TWinUI/Operational (IDs 304/305/306)
try {
    $twEvents = Get-WinEvent -FilterHashtable @{
        LogName   = 'Microsoft-Windows-TWinUI/Operational'
        Id        = 304,305,306
        StartTime = $StartTime
    } -ErrorAction SilentlyContinue

    if ($twEvents) {
        $twHits = $twEvents | Where-Object {
            ($_.Message -like "*$TargetPackageHint*" -or $_.Message -like "*$TargetExeHint*")
        }
        if ($twHits) {
            $matches += $twHits
            Write-Log ("TWinUI hits: {0}" -f $twHits.Count)
        } else {
            Write-Log "TWinUI: no hits."
        }
    } else {
        Write-Log "TWinUI: no events in window."
    }
} catch {
    Write-Log ("TWinUI read error: {0}" -f $_.Exception.Message)
}

# Source 2: AppModel-Runtime/Admin
try {
    $amrEvents = Get-WinEvent -FilterHashtable @{
        LogName   = 'Microsoft-Windows-AppModel-Runtime/Admin'
        StartTime = $StartTime
    } -ErrorAction SilentlyContinue

    if ($amrEvents) {
        $amrHits = $amrEvents | Where-Object {
            ($_.Message -like "*$TargetPackageHint*" -or $_.Message -like "*$TargetExeHint*")
        }
        if ($amrHits) {
            $matches += $amrHits
            Write-Log ("AppModel-Runtime hits: {0}" -f $amrHits.Count)
        } else {
            Write-Log "AppModel-Runtime: no hits."
        }
    } else {
        Write-Log "AppModel-Runtime: no events in window."
    }
} catch {
    Write-Log ("AppModel-Runtime read error: {0}" -f $_.Exception.Message)
}

# Optional fallback: Prefetch timestamp
try {
    $pf = Join-Path $env:WINDIR 'Prefetch'
    if (Test-Path $pf) {
        $pfHits = Get-ChildItem -Path $pf -Filter 'OLK.EXE-*.pf' -ErrorAction SilentlyContinue |
                  Where-Object { $_.LastWriteTime -ge $StartTime }
        if ($pfHits) {
            $matches += $pfHits
            Write-Log ("Prefetch matches (>= StartTime): {0}" -f $pfHits.Count)
        } else {
            Write-Log "Prefetch: no recent OLK.EXE entries."
        }
    } else {
        Write-Log "Prefetch folder not found."
    }
} catch {
    Write-Log ("Prefetch check error: {0}" -f $_.Exception.Message)
}

# Decide
if ($matches -and $matches.Count -gt 0) {
    # Summarize latest event record if present
    $latestEvt = ($matches | Where-Object { $_ -is [System.Diagnostics.Eventing.Reader.EventRecord] } |
                  Sort-Object TimeCreated -Descending | Select-Object -First 1)

    if ($latestEvt) {
        $userSid = $null
        try {
            if ($latestEvt.UserId) { $userSid = $latestEvt.UserId.Value }
        } catch {}
        if (-not $userSid) { $userSid = 'N/A' }

        Write-Log (("Latest evidence: Log={0}, Id={1}, Time={2}, UserSid={3}") -f `
            $latestEvt.LogName, $latestEvt.Id, $latestEvt.TimeCreated, $userSid)

        $firstLine = (($latestEvt.Message -split '\r?\n')[0])
        Write-Log ("Msg: {0}" -f $firstLine)

        Write-Output (("Outlook (new) launch detected within {0} days; latest: {1:yyyy-MM-dd HH:mm:ss} (Log={2}, Id={3})") -f `
            $LookbackDays, $latestEvt.TimeCreated, $latestEvt.LogName, $latestEvt.Id)
    } else {
        Write-Log "Evidence found (e.g., Prefetch), but no event record to summarize."
        Write-Output ("Outlook (new) launch detected within {0} days (non-event evidence)." -f $LookbackDays)
    }

    "==== Detection end (FOUND) {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date) | Out-File -FilePath $LogPath -Append -Encoding UTF8
    exit 1
} else {
    Write-Log "No evidence of Outlook (new) launch in the last $LookbackDays day(s)."
    "==== Detection end (NONE) {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date) | Out-File -FilePath $LogPath -Append -Encoding UTF8
    exit 0
}
