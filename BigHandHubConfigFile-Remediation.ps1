# Define variables
$ConfigFilePath = "C:\Program Files (x86)\BigHand\BigHand\BigHand.Client.exe.config"
$SearchString = "jacksonlewis.net"
$CorrectBrokerLine = '<add key="BrokerAddress" value="net.tcp://BHSecure.jacksonlewis.net:62000/" />'

# Check if the file exists
if (Test-Path $ConfigFilePath) {
    # Read the file as raw text
    $Content = Get-Content -Path $ConfigFilePath -Raw

    # Check if string exists
    if ($Content -match [regex]::Escape($SearchString)) {
        Write-Output "All set. BHSecure string already present. No changes needed."
        exit 0
    } else {
        Write-Output "BHSecure string not found. Attempting remediation..."

        # Read file as an array of lines
        $Lines = Get-Content -Path $ConfigFilePath

        # Replace or insert the correct BrokerAddress line
        $NewLines = foreach ($line in $Lines) {
            if ($line -match '<add\s+key\s*=\s*"BrokerAddress"\s+') {
                # Replace existing BrokerAddress line with the correct one
                $CorrectBrokerLine
            } else {
                $line
            }
        }

        # If no BrokerAddress line existed at all, add it before </appSettings>
        if (-not ($Lines -match '<add\s+key\s*=\s*"BrokerAddress"\s+')) {
            $InsertIndex = ($Lines | Select-String -Pattern '</appSettings>' | Select-Object -First 1).LineNumber
            if ($InsertIndex) {
                $NewLines = $NewLines[0..($InsertIndex-2)] + $CorrectBrokerLine + $NewLines[($InsertIndex-1)..($NewLines.Length-1)]
            } else {
                Write-Output "</appSettings> closing tag not found. Cannot safely insert BrokerAddress."
                exit 1
            }
        }

        # Save the updated lines back to the config file
        $NewLines | Set-Content -Path $ConfigFilePath -Encoding UTF8

        Write-Output "BH Secure BrokerAddress corrected successfully."
        exit 0
    }
} else {
    Write-Output "Config file not found. Exiting."
    exit 1
}
