<#
Intune Remediation - Detection Script (Parent Uptime Included)
- Detects running msiexec.exe
- Records parent process name, PID, command line, and parent uptime
- Exit 1 = Non-compliant (msiexec found; triggers remediation)
- Exit 0 = Compliant (none found)
- Persists details to C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\MsiexecDetection.log
#>

$LogRoot = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\Logs'
$LogPath = Join-Path $LogRoot 'MsiexecDetection.log'

if (-not (Test-Path $LogRoot)) {
    New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null
}

# Rotate if >1MB
try {
    if (Test-Path $LogPath) {
        if ((Get-Item $LogPath).Length -gt 1MB) {
            $archive = Join-Path $LogRoot ('MsiexecDetection_{0:yyyyMMdd_HHmmss}.log' -f (Get-Date))
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

function Format-TimeSpan {
    param([TimeSpan]$Span)
    # Output like "2d 03h 11m 05s" or "03h 11m 05s"
    $days = if ($Span.Days -gt 0) { "{0}d " -f $Span.Days } else { "" }
    "{0}{1:00}h {2:00}m {3:00}s" -f $days, [math]::Abs($Span.Hours), [math]::Abs($Span.Minutes), [math]::Abs($Span.Seconds)
}

function Get-ParentInfo {
    param([uint32]$ParentPid)

    $parentName = "Unknown"
    $parentStart = $null

    # Try Get-Process first (fast, includes StartTime in most cases)
    try {
        $gp = Get-Process -Id $ParentPid -ErrorAction SilentlyContinue
        if ($gp) {
            $parentName = $gp.Name
            try { $parentStart = $gp.StartTime } catch {}
        }
    } catch {}

    # Fallback to CIM for name and CreationDate if StartTime not available
    if (-not $parentStart -or $parentName -eq "Unknown") {
        try {
            $pcim = Get-CimInstance Win32_Process -Filter "ProcessId=$ParentPid" -ErrorAction SilentlyContinue
            if ($pcim) {
                if ($parentName -eq "Unknown" -and $pcim.Name) { $parentName = $pcim.Name }
                if (-not $parentStart -and $pcim.CreationDate) {
                    $parentStart = [Management.ManagementDateTimeConverter]::ToDateTime($pcim.CreationDate)
                }
            }
        } catch {}
    }

    # Compute uptime if we have a start time
    $uptime = $null
    if ($parentStart) {
        try { $uptime = (Get-Date) - $parentStart } catch {}
    }

    [PSCustomObject]@{
        Name      = $parentName
        Pid       = $ParentPid
        StartTime = $parentStart
        Uptime    = $uptime
    }
}

try {
    "==== Detection start {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date) | Out-File -FilePath $LogPath -Append -Encoding UTF8

    $msiProcs = Get-CimInstance Win32_Process -Filter "Name='msiexec.exe'" -ErrorAction SilentlyContinue

    if ($msiProcs) {
        Write-Log "msiexec.exe process(es) detected: $($msiProcs.Count)"

        foreach ($proc in $msiProcs) {
            $parent = Get-ParentInfo -ParentPid $proc.ParentProcessId

            $parentUptimeStr = if ($parent.Uptime) { Format-TimeSpan -Span $parent.Uptime } else { "Unknown" }
            $cmd = $proc.CommandLine
            if ([string]::IsNullOrWhiteSpace($cmd)) { $cmd = "(No command line recorded)" }
            $cmd = ($cmd -replace '\s+', ' ').Trim()

            Write-Log ("PID: {0} | Started By: {1} (PID {2}) | Parent Uptime: {3} | Command: {4}" -f `
                $proc.ProcessId, $parent.Name, $parent.Pid, $parentUptimeStr, $cmd)
        }

        "==== Detection end (FOUND) {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date) | Out-File -FilePath $LogPath -Append -Encoding UTF8

        # Exit 1 triggers remediation and includes a concise summary line in standard output
        $summary = $msiProcs | ForEach-Object {
            $pinfo = Get-ParentInfo -ParentPid $_.ParentProcessId
            $upt   = if ($pinfo.Uptime) { Format-TimeSpan -Span $pinfo.Uptime } else { "Unknown" }
            "PID $_.ProcessId via $($pinfo.Name) (PID $($pinfo.Pid), up $upt)"
        }
        Write-Output ("msiexec detected: " + ($summary -join " | "))
        exit 1
    }
    else {
        Write-Log "No msiexec.exe processes detected."
        "==== Detection end (NONE) {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date) | Out-File -FilePath $LogPath -Append -Encoding UTF8
        exit 0
    }
}
catch {
    Write-Log ("Detection error: {0}" -f $_.Exception.Message)
    exit 1
}
