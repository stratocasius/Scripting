# Remediation Script
# Shows notification, then writes HKCU tag NotificationRemediation=ddMMMyyyy (e.g., 23Jan2026)

$RegPath = "HKCU:\Software\Intune"
$RegName = "NotificationRemediation"
$DateFormat = "ddMMMyyyy"
$todayString = (Get-Date).ToString($DateFormat)

# --- Your notification code ---
Add-Type -AssemblyName System.Windows.Forms 
$Global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -Id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$balloon.BalloonTipText = "I need to borrow your motorcycle!"
$balloon.BalloonTipTitle = "Attention $Env:USERNAME"
$balloon.Visible = $true
$balloon.ShowBalloonTip(9000)

# --- Write/update the tag so detection stays compliant for 30 days ---
try {
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }

    New-ItemProperty -Path $RegPath -Name $RegName -PropertyType String -Value $todayString -Force | Out-Null
    Write-Output "Wrote tag: $RegPath\$RegName = $todayString"
    exit 0
}
catch {
    Write-Output "ERROR: Failed to write tag $RegPath\$RegName. $($_.Exception.Message)"
    exit 1
}
finally {
    # Clean up the notify icon so it doesn't linger
    if ($null -ne $balloon) {
        $balloon.Dispose()
    }
}
