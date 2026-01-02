### ndOffice Enable -Remediation - Remediation Script 02/19/2025
# Define registry paths to check
$RegistryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\NetDocuments.ndMail.OutlookAddIn",
    "HKLM:\SOFTWARE\Microsoft\Office\Word\Addins\NetDocuments.Client.WordAddIn",
    "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\NetDocuments.Client.OutlookAddIn",
    "HKLM:\SOFTWARE\Microsoft\Office\Excel\Addins\NetDocuments.Client.ExcelAddIn",
    "HKLM:\SOFTWARE\Microsoft\Office\PowerPoint\Addins\NetDocuments.Client.PowerPointAddIn"
    "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\MailSync"
)

# Target value
$TargetValueName = "LoadBehavior"
$DesiredValue = 3

### Create function for remediation logging
$LogFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndOfficeAddinsEnabled.HKLM.HKCU-Transcript.log"
Start-Transcript -Path $LogFilePath

### Remediation Script
# Loop through each registry path and set the LoadBehavior DWORD to 3
foreach ($Path in $RegistryPaths) {
    if (-not (Test-Path -Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $TargetValueName -Value $DesiredValue
    Write-Output "Updated LoadBehavior for $Path to $DesiredValue."
}

# Get all user SIDs under HKEY_USERS, excluding system keys
$UserSIDs = Get-ChildItem -Path Registry::HKEY_USERS | Where-Object {
    $_.Name -notmatch "^S-1-5-(18|19|20)$"
}

# Define user registry paths
$UserRegistryPaths = @(
    "Software\Microsoft\Office\Outlook\Addins\NetDocuments.ndMail.OutlookAddIn",
    "Software\Microsoft\Office\Word\Addins\NetDocuments.Client.WordAddIn",
    "Software\Microsoft\Office\Outlook\Addins\NetDocuments.Client.OutlookAddIn"
)

foreach ($UserSID in $UserSIDs) {
    foreach ($UserRegistryPath in $UserRegistryPaths) {
        $RegistryPath = Join-Path -Path $UserSID.PSPath -ChildPath $UserRegistryPath
        if (Test-Path -Path $RegistryPath) {
            try {
                $CurrentValue = (Get-ItemProperty -Path $RegistryPath -Name $TargetValueName -ErrorAction Stop).$TargetValueName
                if ($CurrentValue -ne $DesiredValue) {
                    Set-ItemProperty -Path $RegistryPath -Name $TargetValueName -Value $DesiredValue
                    Write-Output "Updated LoadBehavior for $RegistryPath to $DesiredValue."
                } else {
                    Write-Output "LoadBehavior for $RegistryPath is already set to $DesiredValue."
                }
            } catch {
                Write-Output "An error occurred while processing $RegistryPath $($_.Exception.Message)"
            }
        } else {
            Write-Output "Registry path $RegistryPath does not exist. Skipping."
        }
    }
}


### Remove ndOffice/ndMail from Windows startup, moving the shortcuts to C:\jltools\ndOfficeAddins
# Define the list of file paths to check
$files = @(
    "C:\jltools\ndOfficeAddins\NetDocuments ndMail.lnk",
    "C:\jltools\ndOfficeAddins\NetDocuments ndOffice.lnk"
)

# Define the destination directory
$destination = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"

# Ensure the destination folder exists; if not, create it
if (-not (Test-Path $destination)) {
    New-Item -Path $destination -ItemType Directory -Force
    Write-Output "Created destination folder: $destination"
}

# Loop through each file and move it if it exists
foreach ($file in $files) {
    if (Test-Path $file) {
        try {
            Move-Item -Path $file -Destination $destination -Force -ErrorAction SilentlyContinue
            Write-Output "Moved file: $file to $destination"
        }
        catch {
            Write-Error "Error moving file: $file. $_"
        }
    }
    else {
        Write-Output "File not found: $file"
    }
}

### ndOffice renamed to .exe for functionality
Rename-Item -Path "C:\Program Files (x86)\NetDocuments\ndOffice\ndOffice.DISABLED" -NewName "C:\Program Files (x86)\NetDocuments\ndOffice\ndOffice.exe" -Force -ErrorAction SilentlyContinue
Write-Output "ndOffice.exe renamed to ndOffice.exe at C:\Program Files (x86)\NetDocuments\ndOffice to prevent ndOffice from auto-launching on Enabled Addin PCs on $(Get-Date)."
Write-Output "ndOffice Enabled Addins remediation completed successfully on $(Get-Date)."
Write-Output "ndOffice Enable Addins remediation completed successfully on $(Get-Date)."
### Stop transcript
Stop-Transcript