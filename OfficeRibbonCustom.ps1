Copy-Item 
C:\jltools\OfficeRibbonCustomizations\
reg add "HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook\CustomUI" /v CustomUIXML /t REG_SZ /d "C:\jltools\OfficeRibbonCustomizations\"