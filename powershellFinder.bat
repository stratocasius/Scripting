if((Test-Path -LiteralPath "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727") -ne $true) {  New-Item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727" -force -ea SilentlyContinue }