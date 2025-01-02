# Map G:\ drive
$GDrive = "G:"
$GDrivePath = "\\jacksonlewis.net\shares"
if (!(Test-Path -Path $GDrive)) {
    New-PSDrive -Name "G" -PSProvider FileSystem -Root $GDrivePath -Persist
}

# Map N:\ drive
$NDrive = "N:"
$NDrivePath = "\\jacksonlewis.net\shares\offices"
if (!(Test-Path -Path $NDrive)) {
    New-PSDrive -Name "N" -PSProvider FileSystem -Root $NDrivePath -Persist
}
