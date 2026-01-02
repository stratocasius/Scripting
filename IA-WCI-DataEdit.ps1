$iniPath = "C:\ProgramData\LexisNexis\InterAction\Installation Data\INTRACTN.ini"
$backupPath = "$iniPath.bak"

# Validate the INI file exists
if (-Not (Test-Path $iniPath)) {
    Write-Output "INI file not found. Remediation skipped."
    exit 0
}

# Backup original file
Copy-Item -Path $iniPath -Destination $backupPath -Force

# Prepare updated content
$updatedLines = @()

Get-Content $iniPath | ForEach-Object {
    $line = $_

    # Replace the Data path
    if ($line -match "C:\\ProgramData\\LexisNexis\\InterAction\\Data") {
        $line = $line -replace "C:\\ProgramData\\LexisNexis\\InterAction\\Data", "\\vm-nasuni-01\shares\software\Interaction"
    }

    # Replace the SysData path
    if ($line -match "C:\\ProgramData\\LexisNexis\\InterAction\\SysData") {
        $line = $line -replace "C:\\ProgramData\\LexisNexis\\InterAction\\SysData", "\\vm-nasuni-01\shares\software\Interaction"
    }

    # Increment Install Data Version
    if ($line -match "^Installation Data Version\s*=\s*(\d+)\s*$") {
        $currentVersion = [int]$Matches[1]
        $newVersion = $currentVersion + 1
        $line = "Installation Data Version=$newVersion"
    }

    $updatedLines += $line
}

# Write updated lines back to the file
$updatedLines | Set-Content -Path $iniPath -Encoding UTF8

Write-Output "INI file updated and Install Data Version incremented."

exit 0
