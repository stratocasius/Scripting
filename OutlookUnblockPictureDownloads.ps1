### Outlook - Disables the Don't download pictures automatically for standard HTML emails
New-item -Path 'HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\outlook\options\Mail' -Verbose
New-ItemProperty -Path 'HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\outlook\options\Mail' -Name 'blockextcontent' -Value 0 -PropertyType DWord -ErrorAction SilentlyContinue