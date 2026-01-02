### Office 365 AutoCorrect Update - "Amtrak" added to relevant files for AutoCorrect behavior - 12/18/2024
### Spellings of 'amtrac' and 'amtrack' resolving to Amtrak in O365 Apps.

### Establish logging 
$LogFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\OfficeAutoCorrect-Update.log"
# Start logging
Start-Transcript -Path $LogFile -Append

### Create Backup folder in C:\jltools\ for OfficeAutoCorrectBackup
    # Ensure the destination directory exists
    if (-not (Test-Path -Path "C:\jltools\OfficeAutoCorrectBackup")) {
        New-Item -ItemType Directory -Path "C:\jltools\OfficeAutoCorrectBackup" -Force
        Write-Output "Created C:\jltools\OfficeAutoCorrectBackup folder for backing up users existing MSO1033.acl AutoCorrect file."
    }

### Copy exsisting MSO1033.acl to C:\jltools\ prior to overwriting.
Copy-Item -Path "$env:APPDATA\Microsoft\Office\MSO1033.acl" -Destination "C:\jltools\OfficeAutoCorrectBackup" -Force -ErrorAction Continue -verbose
Write-Output "Copied over MSO1033.acl from $env:USERNAME to C:\jltools\OfficeAutoCorrectBackup folder successfully on $(Get-Date)."
### Copy exsisting ExcludeDictionaryEN0409.lex to C:\jltools\ prior to overwriting.
Copy-Item -Path "$env:APPDATA\Microsoft\UProof\ExcludeDictionaryEN0409.lex" -Destination "C:\jltools\OfficeAutoCorrectBackup" -Force -ErrorAction Continue -verbose

Write-Output "Copied over ExcludeDictionaryEN0409.lex from $env:USERNAME to C:\jltools\OfficeAutoCorrectBackup folder successfully on $(Get-Date)."
# Establish updated file varibles to copy over.
$FilesToCopy = @(
    @{ Source = "MSO1033.acl"; Destination = "$env:APPDATA\Microsoft\Office" },
    @{ Source = "ExcludeDictionaryEN0409.lex"; Destination = "$env:APPDATA\Microsoft\UProof" },
    @{ Source = "File Clients.dic"; Destination = "$env:APPDATA\Microsoft\UProof" }
)

### Loop through each file and copy to the destination
foreach ($File in $FilesToCopy) {
    $Source = $File.Source
    $Destination = $File.Destination

    ### Ensure the destination directory exists
    if (-not (Test-Path -Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }

    ### Copy the file to the destination
    if (Test-Path -Path $Source) {
        Copy-Item -Path $Source -Destination $Destination -Force
        Write-Output "Copied '$Source' to '$Destination'."
    } else {
        Write-Output "The source file '$Source' does not exist. Skipping."
    }
}

### Define registry path and value
$RegistryPath = "HKCU:\Software\Intune"
$RegistryName = "IntuneApp_Office AutoCorrect"
$RegistryValue = "12182024"

### Create the registry key if it doesn't exist
if (-not (Test-Path -Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}

### Write the registry value
Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue
Write-Output "Registry value '$RegistryName' with data '$RegistryValue' added to '$RegistryPath' to add Office AutoCorrect app detection."
Write-Output "Office AutoCorrect update completed on $(Get-Date)."
### Stop logging
Stop-Transcript