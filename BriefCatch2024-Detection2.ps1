$filePath = "$env:APPDATA\bcms\briefcatch_license.key"
$expirationString = "Expire=01-Oct-2023"

# Check if the file exists
if(Test-Path -Path $filePath) {
    $fileContent = Get-Content -Path $filePath -Raw
    # Check if the file contains the expiration string
    if($fileContent -match $expirationString) {
        # Exit with 1 indicating that remediation is required
        Write-Output "License invaild, Running remediation script"
        Exit 1
    } else {
        # Exit with 0 indicating that no action is needed
        Write-Output "License vaild, No remediation needed"
        Exit 0
    }
} else {
    # Exit with 1 indicating that remediation is required
    Exit 1
}
