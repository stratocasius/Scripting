### 

# Target date to match
$targetDate = [datetime]::ParseExact("07/07/2025", "MM/dd/yyyy", $null)

# File name to check
$fileName = "Microsystems.Data.Enterprise.mdxt"

# Global path
$globalPath = "C:\Program Files\Microsystems\Modules\$fileName"

# Function: check file exists and has correct date
function Test-FileModifiedDate {
    param (
        [string]$path
    )
    if (Test-Path $path) {
        $modDate = (Get-Item $path).LastWriteTime.Date
        return $modDate -eq $targetDate
    } else {
        return $false
    }
}

# 1. Check global Program Files path
if (-not (Test-FileModifiedDate -path $globalPath)) {
    Write-Output "Missing or incorrect date in Program Files path $globalPath"
    exit 1
}

# 2. Check each real user profile under C:\Users
$userProfiles = Get-ChildItem "C:\Users" -Directory | Where-Object {
    $_.Name -notlike "Default*" -and $_.Name -ne "Public" -and $_.Name -ne "All Users"
}

foreach ($user in $userProfiles) {
    $userPath = "C:\Users\$($user.Name)\AppData\Local\Microsystems\Modules\$fileName"

    if (-not (Test-FileModifiedDate -path $userPath)) {
        Write-Output "Missing or incorrect date in user profile $userPath"
        exit 1
    }
}

Write-Output "All target files exist and are correctly dated."
exit 0
