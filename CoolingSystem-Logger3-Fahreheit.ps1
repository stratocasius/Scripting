### Cooling System Monitoring Script - SUPER LEAN - 03/14/2026
### Logs only:
###   - CurrentTemperatureF
###   - CurrentTemperatureRaw
### Output is CSV-formatted but saved as .log for easier diagnostics retrieval

$ErrorActionPreference = 'Continue'

$BasePath        = 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs'
$DateStamp       = Get-Date -Format 'MMddyyyy'
$OutCsv          = Join-Path $BasePath "$($env:COMPUTERNAME)-$DateStamp-CoolingSystem-SUPERLEAN.log"
$DurationSeconds = 21600
$IntervalSeconds = 30

# Write header once
if (-not (Test-Path -LiteralPath $OutCsv)) {
    "Timestamp,Computer,Source,Key,Value" | Out-File -LiteralPath $OutCsv -Encoding UTF8
}

function Write-Row([string]$source,[string]$key,[string]$value) {
    $ts = (Get-Date).ToString("o")
    $line = "$ts,$env:COMPUTERNAME,$source,""$key"",""$value"""
    Add-Content -LiteralPath $OutCsv -Value $line -Encoding UTF8
}

# Convert tenths of Kelvin to Fahrenheit
function KelvinX10ToF([uint32]$k10) {
    $c = (($k10 / 10.0) - 273.15)
    [Math]::Round((($c * 9 / 5) + 32), 2)
}

# ------------------------------------------------------------
# Capability discovery (one-time)
# ------------------------------------------------------------
$UseAcpiThermal = $false
try {
    $tzTest = Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop
    if ($tzTest) { $UseAcpiThermal = $true }
} catch {}

Write-Row "Capability" "MSAcpi_ThermalZoneTemperature" "$UseAcpiThermal"

if (-not $UseAcpiThermal) {
    Write-Row "MSAcpi_ThermalZoneTemperature" "Error" "Class not available or returned no data."
    try { schtasks.exe /Delete /TN 'JL-CoolingSystem-WMI-Logger' /F | Out-Null } catch {}
    exit 0
}

$end = (Get-Date).AddSeconds($DurationSeconds)

while ((Get-Date) -lt $end) {
    try {
        $tz = Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop

        foreach ($t in $tz) {
            if ($t.CurrentTemperature -ne $null -and [uint32]$t.CurrentTemperature -gt 0) {
                $f = KelvinX10ToF ([uint32]$t.CurrentTemperature)

                # Only log Fahrenheit when value looks realistic
                if ($f -gt -58 -and $f -lt 302) {
                    Write-Row "MSAcpi_ThermalZoneTemperature" "$($t.InstanceName)\CurrentTemperatureF" "$f"
                }

                # Keep raw reading for troubleshooting/comparison
                Write-Row "MSAcpi_ThermalZoneTemperature" "$($t.InstanceName)\CurrentTemperatureRaw" "$($t.CurrentTemperature)"
            }
        }
    } catch {
        Write-Row "MSAcpi_ThermalZoneTemperature" "Error" "$($_.Exception.Message)"
    }

    Start-Sleep -Seconds $IntervalSeconds
}

# Self-delete task after completion
try { schtasks.exe /Delete /TN 'JL-CoolingSystem-WMI-Logger' /F | Out-Null } catch {}