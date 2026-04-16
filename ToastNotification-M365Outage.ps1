# --- Your notification code ---
Add-Type -AssemblyName System.Windows.Forms 
$Global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -Id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
$balloon.BalloonTipText = "From JL IT: 
We are aware of the M365 outage, Microsoft's actively working to resolve. Please check JLink for any updates."
#$balloon.BalloonTipTitle = "- Attention $Env:USERNAME -"
$balloon.Visible = $true
$balloon.ShowBalloonTip(9000)