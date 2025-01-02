# Define registry key paths and properties
$registryItems = @{
    "HKLM:\SOFTWARE\NetDocuments" = @{
        "OfflineModeNotification" = "None"
    }
    "HKLM:\SOFTWARE\NetDocuments\ndMail" = @{
        "RankingBarEnabled" = "True"
        "ShowSuccessfulToastNotification" = "False"
        "ShowOutlookPanels" = "False"
    }
        "HKLM:\Software\NetVoyage\NetDocuments" = @{
        "DontShowStampConflictDialog" = "True"
        "StampingLocation" = "LastPage"
        "AutoUpdateEnabled" = "False"
        "UseEmbeddedNetWebBrowser" = "True"
        "ndOfficeHandoff" = "pdf"
        "ShowExtOutlookFeatures" = "False"
        "PromptFileEmails" = "False"
    }
    "HKLM:\Software\NetVoyage\NetDocuments\ndSync" = @{
        "PromptForAutomaticUpdates" = "False"
    }
}

# Check and create registry items if not found
foreach ($keyPath in $registryItems.Keys) {
    if (-not (Test-Path $keyPath)) {
        New-Item -Path $keyPath -Force | Write-Output "C:\Windows\Temp\NetDocs-HKLMRegSettings.log"
    }
    
    foreach ($propertyName in $registryItems[$keyPath].Keys) {
        $propertyValue = $registryItems[$keyPath][$propertyName]
        Set-ItemProperty -Path $keyPath -Name $propertyName -Value $propertyValue -Verbose
    }
}

###############################################################################
# Another Idea(Function)
$LogFilePath = "C:\windows\temp\Netdocs-HKLMsettings.log"

# Function to log missing items
function LogMissingItem {
    param (
        [string]$Item
    )
    $message = "Missing: $Item"
    $message | Out-File -FilePath $LogFilePath -Append
}

# Check and create missing registry keys and values
$regItems = @{
    "HKLM:\SOFTWARE\NetDocuments\OfflineModeNotification" = "None"
    "HKLM:\SOFTWARE\NetDocuments\ndMail\RankingBarEnabled" = "True"
    "HKLM:\SOFTWARE\NetDocuments\ndMail\ShowSuccessfulToastNotification" = "False"
    "HKLM:\SOFTWARE\NetDocuments\ndMail\ShowOutlookPanels" = "False"
    "HKLM:\Software\NetVoyage\NetDocuments\DontShowStampConflictDialog" = "True"
    "HKLM:\Software\NetVoyage\NetDocuments\StampingLocation" = "LastPage"
    "HKLM:\Software\NetVoyage\NetDocuments\AutoUpdateEnabled" = "False"
    "HKLM:\Software\NetVoyage\NetDocuments\UseEmbeddedNetWebBrowser" = "True"
    "HKLM:\Software\NetVoyage\NetDocuments\ndOfficeHandoff" = "pdf"
    "HKLM:\Software\NetVoyage\NetDocuments\ShowExtOutlookFeatures" = "False"
    "HKLM:\Software\NetVoyage\NetDocuments\PromptFileEmails" = "False"
    "HKLM:\Software\NetVoyage\NetDocuments\ndSync\PromptForAutomaticUpdates" = "False"
}

foreach ($item in $regItems.Keys) {
    if (-not (Test-Path $item)) {
        New-Item -Path $item.Value -Force | Out-Null
        LogMissingItem -Item $item
    }

    $value = $regItems[$item]
    $valueExists = Test-Path "$item"
    if (-not $valueExists) {
        $valueName = $item -split '\\', 3 | Select-Object -Last 1
        New-ItemProperty -Path $item -Name $valueName -Value $value -Force | Out-Null
        LogMissingItem -Item "$item\$valueName = $value"
    }
}
