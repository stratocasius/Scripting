# Detection Script for PerfMonitor Folder 02/26/2026
# Exit 0 = Folder exists (Compliant)
# Exit 1 = Folder missing (Trigger remediation)

$perfPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PerfMonitor"

if (Test-Path -Path $perfPath -PathType Container) {
    Write-Output "PerfMonitor folder exists."
    exit 0
}
else {
    Write-Output "PerfMonitor folder NOT found."
    exit 1
}