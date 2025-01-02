# Specify the KB number you want to check
$KBNumber = "KB5029921"

# Check if the KB update is installed
$KBInstalled = Get-HotFix | Where-Object { $_.HotFixId -eq $KBNumber }

if ($KBInstalled) {
    Write-Host "$KBNumber is installed."
    
} else {
    Write-Host "$KBNumber is not installed."
}
