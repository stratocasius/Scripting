$Usr = "PuttaS"
Disable-ADAccount -Identity $usr
 
Set-ADAccountPassword -Identity $usr -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "uoymX9:w9zh~7x&m" -Force)
Set-ADAccountPassword -Identity $usr -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "f0Awy)'z~+Z<S\q" -Force)