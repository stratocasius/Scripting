$iniPath = "C:\ProgramData\LexisNexis\InterAction\Installation Data\INTRACTN.ini"
$tempPath = "$env:TEMP\INTRACTN_temp.ini"
$backupPath = "$iniPath.bak"

# Check if file exists
if (-Not (Test-Path $iniPath)) {
    Write-Output "INI file not found: $iniPath"
    exit 1
}

# Backup original file
Copy-Item -Path $iniPath -Destination $backupPath -Force

# Initialize list for modified lines
$updatedLines = @()

# Process each line
Get-Content $iniPath | ForEach-Object {
    $line = $_

    # Replace Data path
    if ($line -match "C:\\ProgramData\\LexisNexis\\InterAction\\Data") {
        $line = $line -replace "C:\\ProgramData\\LexisNexis\\InterAction\\Data", "\\jacksonlewis\shares\software"
    }

    # Replace SysData path
    if ($line -match "C:\\ProgramData\\LexisNexis\\InterAction\\SysData") {
        $line = $line -replace "C:\\ProgramData\\LexisNexis\\InterAction\\SysData", "\\jacksonlewis\shares\software"
    }

    # Increment Install Data Version
    if ($line -match "^Install Data Version\s*=\s*(\d+)") {
        $currentVersion = [int]$Matches[1]
        $newVersion = $currentVersion + 1
        $line = "Install Data Version=$newVersion"
    }

    $updatedLines += $line
}

# Write changes back to file
$updatedLines | Set-Content -Path $iniPath -Encoding UTF8

Write-Output "INI file successfully updated."

exit 0