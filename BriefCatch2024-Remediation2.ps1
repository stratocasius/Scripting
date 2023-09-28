$filePath = "$env:APPDATA\bcms\BriefCatch_license.key"
$newContent = @"
#
# Brief Catch for Microsoft Office License File
#
# --------------------------- DO NOT MODIFY -------------------------------
# Modifying the content of this file will render your license unusable!
# ----------------------- DO NOT MODIFY THIS FILE -------------------------
#

[General]
Product=BCMS
Version=1
Licensee=Jackson Lewis
Seats=99999
KeyNo=131773
Expire=01-Oct-2024
#2599909C8FC3E9F868C5208DDA79DA92
"@

# Ensure the directory exists
$directory = Split-Path -Path $filePath -Parent
if(-not (Test-Path -Path $directory)) {
    New-Item -Path $directory -ItemType Directory
}

# Replace Windows line endings with Unix ones
$newContent = $newContent -replace "`r`n", "`n"

# Write the new content to the file with UTF8 encoding and No BOM
$utf8WithoutBOM = New-Object System.Text.UTF8Encoding $false
$writer = New-Object System.IO.StreamWriter $filePath, $false, $utf8WithoutBOM
$writer.Write($newContent)
$writer.Close()
# Output to C:\Windows\Temp for local confirmation
$Today = Get-Date
New-Item -path "C:\Windows\Temp\BriefCatch2.x-2024.log" -ItemType File -Force
Set-Content -Path "C:\Windows\Temp\BriefCatch2.x-2024.log" -Value "Briefcatch's 2024 license file was create on $Today" -Force -ErrorAction SilentlyContinue

