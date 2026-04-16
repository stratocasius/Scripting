Add-Type -AssemblyName System.Windows.Forms 
$Global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -Id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::info # warning, error, info
$balloon.BalloonTipText = "I need to borrow your motorcycle!"
$balloon.BalloonTipTitle = "Attention $Env:u "
$balloon.Visible = $true
$balloon.ShowBalloonTip(9000)