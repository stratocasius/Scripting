<#

Path: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\StickyUpdates

Rules:
- Exit 1 (With issues): any REG_SZ date in (2025-10-01 00:00:00 .. 2025-10-31 23:59:59], inclusive upper bound
- Exit 0: no REG_SZ entries (excluding Default) OR all dates <= 2025-09-30 23:59:59
- Dates > 2025-10-31 23:59:59 do not trigger Exit 1

Transcript:
C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\StickyUpdates-Transcript.log
#>

$RegPath     = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\StickyUpdates'
$fmt         = 'yyyy-MM-dd HH:mm:ss'
$okCutoff    = [datetime]::ParseExact('2025-09-30 23:59:59', $fmt, $null)
$issueCutoff = [datetime]::ParseExact('2025-10-31 23:59:59', $fmt, $null)

# --- Transcript setup ---
$TranscriptDir  = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\Logs'
$TranscriptPath = Join-Path $TranscriptDir 'StickyUpdates-Transcript.log'
if (-not (Test-Path $TranscriptDir)) { New-Item -Path $TranscriptDir -ItemType Directory -Force | Out-Null }

try {
    Start-Transcript -Path $TranscriptPath -Append -ErrorAction SilentlyContinue
    Write-Output ("==== Detection started: {0:yyyy-MM-dd HH:mm:ss} ====" -f (Get-Date))
} catch {
    Write-Output ("Warning: could not start transcript: {0}" -f $_.Exception.Message)
}

function TryParse-Date([string]$s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return $null }
    try {
        return [datetime]::ParseExact($s.Trim(), $fmt, [System.Globalization.CultureInfo]::InvariantCulture)
    } catch {
        try { return [datetime]::Parse($s, [System.Globalization.CultureInfo]::InvariantCulture) } catch { return $null }
    }
}

try {
    if (-not (Test-Path $RegPath)) {
        Write-Output "No issues: key not found."
        try { Stop-Transcript | Out-Null } catch {}
        exit 0
    }

    $item = Get-Item -Path $RegPath -ErrorAction SilentlyContinue
    if (-not $item) {
        Write-Output "No issues: key not accessible."
        try { Stop-Transcript | Out-Null } catch {}
        exit 0
    }

    # Get all REG_SZ values except (Default)
    $props = (Get-ItemProperty -LiteralPath $RegPath -ErrorAction SilentlyContinue).PSObject.Properties |
             Where-Object { $_.Name -ne '(default)' -and $_.MemberType -eq 'NoteProperty' }

    if (-not $props -or $props.Count -eq 0) {
        Write-Output "No issues: no REG_SZ values."
        try { Stop-Transcript | Out-Null } catch {}
        exit 0
    }

    # Evaluate values
    $offenders = @()
    foreach ($p in $props) {
        $valStr = [string]$p.Value
        $dt = TryParse-Date $valStr
        if ($dt) {
            # Issue range: > okCutoff AND <= issueCutoff
            if ($dt -le $issueCutoff -and $dt -gt $okCutoff) {
                $offenders += @{ Name = $p.Name; Data = $valStr; Date = $dt }
            }
        }
        # Non-date strings are ignored
    }

    if ($offenders.Count -gt 0) {
        $lines = $offenders | ForEach-Object { $_.Data }
        Write-Output ("Update(s) Pending - Downloaded and/or installed on: {0}" -f ($lines -join ' | '))
        try { Stop-Transcript | Out-Null } catch {}
        exit 1
    } else {
        Write-Output "No issues: no matching REG_SZ values."
        try { Stop-Transcript | Out-Null } catch {}
        exit 0
    }
}
catch {
    Write-Output ("Detection error: {0}" -f $_.Exception.Message)
    try { Stop-Transcript | Out-Null } catch {}
    exit 1
}