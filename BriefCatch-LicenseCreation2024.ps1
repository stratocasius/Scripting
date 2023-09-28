New-Item -Path "$env:Appdata\bcms\Briefcatch_License.key" -ItemType File -Force
Set-Content -Path "$env:Appdata\bcms\Briefcatch_License.key" -Value "#
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
#2599909C8FC3E9F868C5208DDA79DA92"

$Today = Get-Date
New-Item -path "C:\Windows\Temp\BriefCatch2.x-2024.log" -ItemType File -Force
Set-Content -Path "C:\Windows\Temp\BriefCatch2.x-2024.log" -Value "Briefcatch's 2024 license file was create on $Today" -Force -ErrorAction SilentlyContinue
