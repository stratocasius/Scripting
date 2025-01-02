$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

Stop-Process -Name winword -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name outlook -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name excel -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name powerpnt -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name chrome -Force -Verbose -ErrorAction SilentlyContinue
# Stop-Process -Name msedge -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name ndOffice -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name NetDocuments.ndMail.Application -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name ndClickWinTray -Force -Verbose -ErrorAction SilentlyContinue
Stop-Process -Name powerPDF -Force -Verbose -ErrorAction SilentlyContinue
### ndClick Removal
# cmd /c WMIC.exe product where "name like 'Netdocuments ndClick%'" call uninstall > C:\Windows\Temp\ndClick-Removal.log
# Define the uninstall keys
foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($displayName -like "Netdocuments ndClick") {
            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            
            # Log details
            write-output "Found $displayName with version $displayVersion, Uninstalling"
            
            # Uninstall the software
            if ($uninstallString -like "MsiExec.exe*") {
                $uninstallString = $uninstallString -replace '/I', '/X'
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /l*v C:\Windows\temp\ndClick-UNINSTALL.log /norestart"
            }
        
            write-output "Attempted to uninstall $displayName $displayVersion."
        }
    }
}

### ndOffice app installations
$ndOffice="ndOfficeSetup.msi"
$ndOfficeARGs="/I $ndOffice /qn /l C:\Windows\Temp\ndOffice341-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndOfficeARGs -wait -nonewwindow
$ndMail="ndMailSetup.msi"
$ndMailARGs="/I $ndMail /qn /l C:\Windows\Temp\ndMail112-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailARGs -wait -nonewwindow
$ndMailFM="ndMailFolderMappingx64.msi"
$ndMailFMARGs="/I $ndMailFM /qn /l C:\Windows\Temp\ndMailFM8834-INSTALL.log"
Start-Process "msiexec.exe" -ArgumentList $ndMailFMARGs -wait -nonewwindow

### Relaunch ndOffice for end-user
Start-Process -FilePath "C:\Program Files (x86)\NetDocuments\ndOffice\ndOffice.exe"


