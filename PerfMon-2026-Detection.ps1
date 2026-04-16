### Detection Script for PerfMonitor Folder 03/10/2026
# PerfMon-2026-Detection3.ps1
# Detection Script for DataCollector01.BLG
# Exit 0 = File exists (Compliant) + output size/date modified
# Exit 1 = File missing (Trigger remediation)

$blgFilePath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\DataCollector01.BLG"

if (Test-Path -Path $blgFilePath -PathType Leaf) {
    $file = Get-Item -Path $blgFilePath -ErrorAction Stop

    $sizeBytes = [int64]$file.Length
    $sizeMB = [Math]::Round(($sizeBytes / 1MB), 2)
    $lastModified = $file.LastWriteTime

    Write-Output ("Compliant: DataCollector01.BLG exists. Size={0} bytes ({1} MB). LastModified={2}" -f $sizeBytes, $sizeMB, $lastModified)
    exit 0
}
else {
    Write-Output "Non-compliant: DataCollector01.BLG NOT found."
    exit 1
}