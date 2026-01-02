### Adobe Acrobat Removal - 12/31/2025 
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\AdobeAcrobatSuite-Removal-Transcript.log"
### Start logging
Start-Transcript -Append $logFilepath
### Kill remnant processes if found running.
Stop-Process -Name Acrobat -Force -ErrorAction SilentlyContinue
Stop-Process -Name acrotray -Force -ErrorAction SilentlyContinue
Stop-Process -Name winword -Force -ErrorAction SilentlyContinue
Stop-Process -Name outlook -Force -ErrorAction SilentlyContinue
Stop-Process -Name excel -Force -ErrorAction SilentlyContinue
Stop-Process -Name powerpnt -Force -ErrorAction SilentlyContinue
Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue
Stop-Process -Name msedge -Force -ErrorAction SilentlyContinue
Stop-Process -Name ndOffice -Force -ErrorAction SilentlyContinue
Stop-Process -Name NetDocuments.ndMail.Application -Force -ErrorAction SilentlyContinue
Stop-Process -Name ndClickWinTray -Force -ErrorAction SilentlyContinue
Stop-Process -Name ndAdobe -Force -ErrorAction SilentlyContinue
Stop-Process -Name powerPDF -Force -ErrorAction SilentlyContinue

### Adobe Acrobat (64-bit) removal if found
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($displayName -like "Adobe Acrobat (64-bit)") {
            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            # Log details
            Write-Output "Found $displayName with version $displayVersion, Uninstalling"
                        # Uninstall the software
            if ($uninstallString -like "MsiExec.exe*") {
                $uninstallString = $uninstallString -replace '/I', '/X'
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /norestart /l*v C:\Programdata\Microsoft\IntuneManagementExtension\Logs\AdobeAcrobatPro-UNINSTALL.log"
            }
               Write-Output "Attempted to uninstall $displayName $displayVersion."
               Write-Output "Successfully uninstalled $displayName $displayVersion at $(Get-Date)."

        }
    }
}

### A/V Exclusion for Adobe Genuine Service removal.
#region Adobe Acrobat installation
# Adding gccustomhook.exe to CFA exclusion list
Write-Output "Adding gccustomhook.exe to CFA exclusion list..."
Add-MpPreference -ControlledFolderAccessAllowedApplications "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AdobeGenuineClient\customhook\gccustomhook.exe" -Force 
Write-Output "gccustomhook.exe added to CFA exclusion list."
Set-Location -Path "C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient"
Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /norestart /l*v C:\Programdata\Microsoft\IntuneManagementExtension\Logs\AdobeGenuineSvcs-UNINSTALL.log"
Remove-MpPreference -ControlledFolderAccessAllowedApplications "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\AdobeGenuineClient\customhook\gccustomhook.exe" -Force
Write-Output "gccustomhook.exe added to CFA exclusion list."


### Adobe Creative Cloud removal if found
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($displayName -like "Test-Acrobat25.1") {
            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            # Log details
            Write-Output "Found $displayName with version $displayVersion, Uninstalling"
                        # Uninstall the software
            if ($uninstallString -like "MsiExec.exe*") {
                $uninstallString = $uninstallString -replace '/I', '/X'
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /norestart /l*v C:\Programdata\Microsoft\IntuneManagementExtension\Logs\AdobeCreativeCloud-UNINSTALL.log"
            }
               Write-Output "Attempted to uninstall $displayName $displayVersion."
               Write-Output "Successfully uninstalled $displayName $displayVersion at $(Get-Date)."

        }
    }
}

#######################
### ndAdobe removal if found
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($displayName -like "Netdocuments ndAdobe") {
            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            # Log details
            Write-Output "Found $displayName with version $displayVersion, Uninstalling"
                        # Uninstall the software
            if ($uninstallString -like "MsiExec.exe*") {
                $uninstallString = $uninstallString -replace '/I', '/X'
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /norestart /l*v C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndAdobe-UNINSTALL.log"
            }
               Write-Output "Attempted to uninstall $displayName $displayVersion."
               Write-Output "Successfully uninstalled $displayName $displayVersion at $(Get-Date)."

        }
    }
}

### Removal of Adobe related Task Scheduler items
Unregister-ScheduledTask -TaskName "Adobe Acrobat Update Task" -Confirm:$false
Write-Output "Task Scheduler item Adobe Acrobat Update Task removed on $(Get-Date)"
Unregister-ScheduledTask -TaskName "Launch Adobe CCXProcess" -Confirm:$false
Write-Output "Task Scheduler item Launch Adobe CCXProcess removed on $(Get-Date)"
### Stop logging
Stop-Transcript