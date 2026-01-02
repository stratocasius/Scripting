### BigHand 5.18 Suite for Nerdio - 11/02/2025
### Using blob storage for content delivery.
###############################################################################
### Create logging
$LogFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\BigHand5.18-Nerdio-Transcript.log"
Start-Transcript "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\BigHand5.18-Nerdio-Transcript.log"
# Suppress the progress bar
$ProgressPreference = 'SilentlyContinue'

# Set ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
# Log directory & transcript
$LogRoot = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"

# Installer log paths
$HubLog      = Join-Path $LogRoot "BigHandHub5.18-Nerdio-INSTALL.log"
$NowLog      = Join-Path $LogRoot "BigHandDesktopAssistant5.18-Nerdio-INSTALL.log"
$NDLog       = Join-Path $LogRoot "BigHand-NetDocs-Integration-5.18-Nerdio-INSTALL.log"

# URL and destination path staging for BigHand MSIs.
$url = "https://jlgeneralstorage.blob.core.windows.net/endpoint/BigHand.msi"
$dest = "C:\jltools\BigHand-Nerdio\BigHand.msi"
New-Item -Path "C:\jltools\BigHand-Nerdio" -ItemType Directory -Force -ErrorAction SilentlyContinue
# Download BigHand Hub 5.18
Invoke-WebRequest -Uri "https://jlgeneralstorage.blob.core.windows.net/endpoint/BigHand.msi" -OutFile "C:\jltools\BigHand-Nerdio\BigHand.msi"
#################################
$url = "https://jlgeneralstorage.blob.core.windows.net/endpoint/BigHandNow.msi"
$dest = "C:\jltools\BigHand-Nerdio\BigHandNow.msi"
# Download BigHandNow.msi
Invoke-WebRequest -Uri $url -OutFile "C:\jltools\BigHand-Nerdio\BigHandNow.msi"
###
$url = "https://jlgeneralstorage.blob.core.windows.net/endpoint/BigHandIntegrationwithNetDocuments.msi"
$dest = "C:\jltools\BigHand-Nerdio\BigHandIntegrationwithNetDocuments.msi"
# Download BigHandIntegrationwithNetDocuments.msi
Invoke-WebRequest -Uri $url -OutFile "C:\jltools\BigHand-Nerdio\BigHandIntegrationwithNetDocuments.msi"

### BigHand app installations
$setupPath = "C:\jltools\BigHand-Nerdio\BigHand.msi"
if (Test-Path $setupPath) {
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"C:\jltools\BigHand-Nerdio\BigHand.msi`" TRANSFORMS=`"Hub_AD.mst`" BROKERADDRESS=BHSecure.jacksonlewis.net /qn /NORESTART ALLUSERS=2 /l*v `"$HubLog`"" -Wait -NoNewWindow
    Write-Host "Installation of BigHand Hub 5.18 completed at $(get-Date)."
} else {
    Write-Host "Error - BigHand Hub 5.18 not found at the specified path."
}
### BigHand Now Assistant 5.18
$setupPath = "C:\jltools\BigHand-Nerdio\BigHandNow.msi"
if (Test-Path $setupPath) {
    Start-Process "msiexec.exe" -ArgumentList "/i `"BigHandNow.msi`" TRANSFORMS=`"Now_AD_NoStartUp.mst`" BROKERADDRESS=bhsecure.jacksonlewis.net /qn /NORESTART ALLUSERS=2 /l*v `"$NowLog`"" -Wait -NoNewWindow
    Write-Host "Installation of BigHand Now Assistant 5.18 completed at $(get-Date)."
} else {
    Write-Host "Error - BigHand Now Assistant 5.18 not found at the C:\jltools\BigHand-Nerdio\ path on $(Get-Date)."
}

### BigHand NetDocs Integration 5.18
$setupPath = "C:\jltools\BigHand-Nerdio\BigHandIntegrationwithNetDocuments.msi"
if (Test-Path $setupPath) {
    Start-Process "msiexec.exe" -ArgumentList "/i `"BigHandIntegrationwithNetDocuments.msi`" ADDLOCAL=MainFeature,NowFeature /qn /l*v `"$NDLog`"" -Wait -NoNewWindow
    Write-Host "Installation of BigHand NetDocs Integration completed at $(get-Date)."
} else {
    Write-Host "Error - BigHand NetDocs Integration 5.18 not found at the C:\jltools\BigHand-Nerdio\ path on $(Get-Date)."
}

### Folder cleanup
Set-Location -Path "C:\"
Remove-Item -Path "C:\BigHand-Nerdio\" -Recurse -Force
Write-Output "Folder cleaned up and removed from C:\jltools\ndOffice-nerdio"

### Config.exe checker
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
                
            }
        }

        # Save the updated lines back to the config file
        $NewLines | Set-Content -Path $ConfigFilePath -Encoding UTF8

        Write-Output "BH Secure BrokerAddress corrected successfully."
        
    }
} else {
    Write-Output "Config file not found. Exiting."
    
}

# Calculate script duration
$global:ScriptEndTime = Get-Date
$global:Duration = $ScriptEndTime - $ScriptStartTime
Write-Output ("BigHand Superpak install total script runtime: {0} minutes {1} seconds" -f $Duration.Minutes, $Duration.Seconds)
### Stop Transcript
Stop-Transcript