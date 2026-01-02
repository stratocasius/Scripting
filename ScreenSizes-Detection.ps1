<#
Detection: Physical Screen Dimensions (EDID) – Diagonal Only
- Logs only the diagonal size in inches, one line per display.
- Output example: "DiagonalInches: 23.62"
#>

#region Setup & Logging
$ErrorActionPreference = 'Stop'
$logDir  = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\Logs'
$logFile = Join-Path $logDir 'MonitorDimensions.log'
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }

try {
    Start-Transcript -Path $logFile -Append -ErrorAction SilentlyContinue | Out-Null
} catch { }
#endregion

function Convert-CmToInches([double]$cm) {
    if ($cm -le 0) { return [double]::NaN }
    return [math]::Round(($cm / 2.54), 2)
}

function Get-MonitorDiagonal {
    [CmdletBinding()]
    param()

    $monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ErrorAction Stop |
                Where-Object { $_.Active -eq $true }

    $results = @()
    foreach ($m in $monitors) {
        $wIn = Convert-CmToInches $m.MaxHorizontalImageSize
        $hIn = Convert-CmToInches $m.MaxVerticalImageSize
        if ($wIn -gt 0 -and $hIn -gt 0) {
            $diagIn = [math]::Round([math]::Sqrt(($wIn * $wIn) + ($hIn * $hIn)), 2)
            $results += $diagIn
        }
    }
    return $results
}

$hadError = $false
$diagonals = @()

try {
    $diagonals = Get-MonitorDiagonal
} catch {
    $hadError = $true
    Write-Warning "Failed to query monitor information: $($_.Exception.Message)"
}

if ($diagonals.Count -gt 0) {
    $joined = $diagonals -join ', '
    Write-Output "Screen Size(s) Diagonal in Inches: $joined"
} else {
    Write-Output "No active monitors or diagonal data found."
}

try { Stop-Transcript | Out-Null } catch { }

if ($hadError -or $diagonals.Count -eq 0) {
    exit 1
} else {
    exit 0
}
