### Citrix Workspace 22.3.6002.6116 - Requirement script for only targeting PCs with 19.12.7000.10 installs.
### 12/12/2024
### Establish transcript
$logFilepath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\CitrixWorkspace-Requirement.log"
### Start logging
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\CitrixWorkspace-Requirement.log"

# Define the registry path and value to check
$RegistryPath = "HKLM:\SOFTWARE\WOW6432Node\Citrix\InstallDetect\{A9852000-047D-11DD-95FF-0800200C9A66}"
$RequiredDisplayVersion = "19.12.7000.10"

# Initialize exit code (0 = meets requirements, 1 = does not meet requirements)
$ExitCode = 1

# Check if the registry key exists
if (Test-Path -Path $RegistryPath) {
    # Get the DisplayVersion value from the registry
    $DisplayVersion = (Get-ItemProperty -Path $RegistryPath).DisplayVersion

    # Check if the DisplayVersion matches the required value
    if ($DisplayVersion -eq $RequiredDisplayVersion) {
        Write-Output "Citrix Workspace key exists, and DisplayVersion matches the required value: $RequiredDisplayVersion."
        $ExitCode = 0
    } else {
        Write-Output "Citrix Workspace key exists, but DisplayVersion does not match. Found: $DisplayVersion, Required: $RequiredDisplayVersion."
    }
} else {
    Write-Output "Citrix Workspace does not exist: $RegistryPath."
}

# Exit with the appropriate code
exit $ExitCode
Stop-Transcript