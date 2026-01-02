### Office 365 AutoCorrect Uninstall - Removal script for Office AutoCorrect app(Amtrak)  - 12/29/2024
### Establish detection varibles
$RegistryPath = "HKCU:\Software\Intune"
$RegistryName = "IntuneApp_Office AutoCorrect"
$LogFilePath = "C:\programdata\Microsoft\IntuneManagementExtension\Logs\OfficeAutoCorrect-Uninstall.log"

# Start transcript
Start-Transcript -Path $LogFilePath -Append

try {
    # Check if the registry path exists
    if (Test-Path $RegistryPath) {
        Write-Output "Registry path exists: $RegistryPath"

        # Check if the registry value exists
        $RegistryKey = Get-Item -Path $RegistryPath
        if ($RegistryKey.GetValue($RegistryName, $null) -ne $null) {
            Write-Output "Registry value '$RegistryName' for Office AutoCorrect application does exists. Deleting..."

            # Remove the registry value
            Remove-ItemProperty -Path $RegistryPath -Name $RegistryName
            Write-Output "Registry value '$RegistryName' for Office AutoCorrect application was deleted successfully. Visit C:\jltools\OfficeAutoCorrectBackup to retrieve original files from %APPDATA%\Microsoft and %APPDATA\Microsoft\UProof: MSO1033.acl(%AppData%\Microsoft\Office), ExcludeDictionaryEN0409.lex and File Clients.dic(%AppData%\Microsoft\UProof)"
        } else {
            Write-Output "Registry value '$RegistryName' for Office AutoCorrect application does not exist. No action taken."
        }
    } else {
        Write-Output "Registry path does not exist for Office AutoCorrect application detection: $RegistryPath"
    }
} catch {
    Write-Output "An error occurred uninstall Office AutoCorrect application! $_"
} finally {
    # Stop transcript
    Stop-Transcript
}