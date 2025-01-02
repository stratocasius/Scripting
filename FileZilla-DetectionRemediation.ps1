### FileZilla Detection
# Define the uninstall keys
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

$found = $false
$version = ""

# Search through uninstall keys
foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $properties = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
        if ($properties.DisplayName -like "FileZilla Client%") {
            $found = $true
            $version = $properties.DisplayVersion
            break
        }
    }
    if ($found) {
        break
    }
}

# Exit with status code 1 if found, 0 if not found
if ($found) {
    write-output "FileZilla Client Version $version found. Uninstalling."
    exit 1
} else {
    write-output "FileZilla Client not found."
    exit 0
}



####################################################################################################
### FileZilla Remediation
# Define the log path
$logPath = "C:\windows\temp\FileZilla-Removal.log"

# Define the uninstall keys
$uninstallKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

foreach ($path in $uninstallKeys) {
    Get-ChildItem $path | ForEach-Object {
        $displayName = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($displayName -eq "Cisco AnyConnect Secure Mobility Client") {
            $displayVersion = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty DisplayVersion -ErrorAction SilentlyContinue
            $uninstallString = Get-ItemProperty $_.PSPath | Select-Object -ExpandProperty UninstallString -ErrorAction SilentlyContinue
            
            # Log details
            write-output "Found $displayName with version $displayVersion, Uninstalling"
            
            # Uninstall the software
            if ($uninstallString -like "MsiExec.exe*") {
                $uninstallString = $uninstallString -replace '/I', '/X'
                Start-Process -Wait "msiexec.exe" -ArgumentList "$($uninstallString.Split(' ')[-1]) /qn /l*v $logPath /norestart"
            }
        
            write-output "Attempted to uninstall $displayName $displayVersion."
        }
    }
}

