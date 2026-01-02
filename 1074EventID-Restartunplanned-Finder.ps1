<#
Intune Detection – Last Restart Event (User32 ID 1074)
Purpose:
- Detects and reports the most recent system restart (Event ID 1074)
- Outputs the reason (Planned / Unplanned / Unknown) and the initiating process
Log: C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\RestartEvent-1074.log
#>

$ErrorActionPreference = 'SilentlyContinue'
$logDir  = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs"
$logFile = Join-Path $logDir 'RestartEvent-1074.log'
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }

try { Start-Transcript -Path $logFile -Append | Out-Null } catch {}

try {
    # Get the most recent Event ID 1074 from the System log
    $evt = Get-WinEvent -FilterHashtable @{LogName='System'; ID=1074} -MaxEvents 1

    if ($null -ne $evt) {
        $msg = $evt.Message.Trim()

        # Determine if restart was Planned or Unplanned
        $reason = if ($msg -match 'planned') {
            'Planned'
        } elseif ($msg -match 'unplanned') {
            'Unplanned'
        } else {
            'Unknown'
        }

        # Identify the process or user that initiated the restart
        $initiator = if ($msg -match 'The process (.*?) has initiated') {
            ($matches[1]).Trim()
        } else {
            'Unknown'
        }

        Write-Output "Last Restart Event (1074) - Time: $($evt.TimeCreated) | Reason: $reason | Initiated By: $initiator"
        Write-Output "Raw Message: $msg"
        exit 0   # Compliant (event found)
    }
    else {
        Write-Output "No Event ID 1074 found in System log."
        exit 1   # With Issues
    }
}
catch {
    Write-Warning "Error querying Event ID 1074: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Stop-Transcript | Out-Null } catch {}
}
