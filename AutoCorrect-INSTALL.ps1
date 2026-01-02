# Define file paths and target directories
$FilesToCopy = @(
    @{ Source = "MSO1033.acl"; Destination = "$env:APPDATA\Microsoft\Office" },
    @{ Source = "ExcludeDictionaryEN0409.lex"; Destination = "$env:APPDATA\Microsoft\UProof" },
    @{ Source = "File Clients.dic"; Destination = "$env:APPDATA\Microsoft\UProof" }
)

# Loop through each file and copy to the destination
foreach ($File in $FilesToCopy) {
    $Source = $File.Source
    $Destination = $File.Destination

    # Ensure the destination directory exists
    if (-not (Test-Path -Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }

    # Copy the file to the destination
    if (Test-Path -Path $Source) {
        Copy-Item -Path $Source -Destination $Destination -Force
        Write-Output "Copied '$Source' to '$Destination'."
    } else {
        Write-Output "Source file '$Source' does not exist. Skipping."
    }
}

# Define registry path and value
$RegistryPath = "HKCU:\Software\Intune"
$RegistryName = "Remediation_AutoCorrect"
$RegistryValue = "12112024"

# Create the registry key if it doesn't exist
if (-not (Test-Path -Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}

# Write the registry value
Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue
Write-Output "Registry value '$RegistryName' with data '$RegistryValue' added to '$RegistryPath'."

Write-Output "Script execution completed."