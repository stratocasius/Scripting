### Cooling System Monitoring Script - 03/14/2026

$ErrorActionPreference = 'Continue'

$BasePath        = 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs'
$DateStamp       = Get-Date -Format 'MMddyyyy'
$OutCsv          = Join-Path $BasePath "$($env:COMPUTERNAME)-$DateStamp-CoolingSystem.log"
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

# Convert tenths of Kelvin to Celsius when applicable
function KelvinX10ToC([uint32]$k10) {
    # (K/10) - 273.15
    [Math]::Round((($k10 / 10.0) - 273.15), 2)
}

$end = (Get-Date).AddSeconds($DurationSeconds)

while ((Get-Date) -lt $end) {

    # --- ACPI Thermal Zone Information ---
    try {
        $tz = Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop
        foreach ($t in $tz) {
            if ($t.CurrentTemperature -ne $null) {
                $c = KelvinX10ToC $t.CurrentTemperature
                Write-Row "MSAcpi_ThermalZoneTemperature" "$($t.InstanceName)\CurrentTemperatureC" "$c"
                Write-Row "MSAcpi_ThermalZoneTemperature" "$($t.InstanceName)\CurrentTemperatureRaw" "$($t.CurrentTemperature)"
            }
            if ($t.CriticalTripPoint -ne $null) { Write-Row "MSAcpi_ThermalZoneTemperature" "$($t.InstanceName)\CriticalTripPointRaw" "$($t.CriticalTripPoint)" }
            if ($t.PassiveTripPoint  -ne $null) { Write-Row "MSAcpi_ThermalZoneTemperature" "$($t.InstanceName)\PassiveTripPointRaw"  "$($t.PassiveTripPoint)" }
        }
    } catch {
        Write-Row "MSAcpi_ThermalZoneTemperature" "Error" "$($_.Exception.Message)"
    }

    # --- Fan devices ---
    try {
        $fans = Get-CimInstance -Namespace root\cimv2 -ClassName Win32_Fan -ErrorAction Stop
        foreach ($f in $fans) {
            Write-Row "Win32_Fan" "$($f.DeviceID)\Name" "$($f.Name)"
            Write-Row "Win32_Fan" "$($f.DeviceID)\Status" "$($f.Status)"
            if ($f.CurrentSpeed -ne $null) { Write-Row "Win32_Fan" "$($f.DeviceID)\CurrentSpeed" "$($f.CurrentSpeed)" }
            if ($f.DesiredSpeed -ne $null) { Write-Row "Win32_Fan" "$($f.DeviceID)\DesiredSpeed" "$($f.DesiredSpeed)" }
        }
    } catch {
        Write-Row "Win32_Fan" "Error" "$($_.Exception.Message)"
    }

    # --- Temperature probes ---
    try {
        $probes = Get-CimInstance -Namespace root\cimv2 -ClassName Win32_TemperatureProbe -ErrorAction Stop
        foreach ($p in $probes) {
            Write-Row "Win32_TemperatureProbe" "$($p.DeviceID)\Name" "$($p.Name)"
            if ($p.CurrentReading -ne $null) { Write-Row "Win32_TemperatureProbe" "$($p.DeviceID)\CurrentReading" "$($p.CurrentReading)" }
            if ($p.Status -ne $null) { Write-Row "Win32_TemperatureProbe" "$($p.DeviceID)\Status" "$($p.Status)" }
        }
    } catch {
        Write-Row "Win32_TemperatureProbe" "Error" "$($_.Exception.Message)"
    }

    Start-Sleep -Seconds $IntervalSeconds
}

# Self-delete task after completion
try { schtasks.exe /Delete /TN 'JL-CoolingSystem-WMI-Logger' /F | Out-Null } catch {}