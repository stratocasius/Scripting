# Check free space on C:\ drive
$drive = Get-PSDrive -Name C -ErrorAction SilentlyContinue

if ($null -eq $drive) {
    Write-Output "C: drive not found."
    exit 1
}

$freeGB = [math]::Round($drive.Free / 1GB, 2)
Write-Output "Free space on C: drive: $freeGB GB"

if ($freeGB -lt 15) {
    Write-Output "Less than 15 GB free on C:. Marking as non-compliant. | FreeSpace: $freeGB GB"
    exit 1
} else {
    Write-Output "Sufficient space on C:. Marking as compliant. | FreeSpace: $freeGB GB"
    exit 0
}
