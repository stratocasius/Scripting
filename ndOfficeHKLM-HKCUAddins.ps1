### ndOffice Addin Disablement for M365 Apps (Excel, Outlook, PowerPoint) - 01/24/2025
### Create function for remediation logging
$LogFilePath = "C:\Programdata\Microsoft\IntuneManagementExtension\Logs\ndOfficeAddins-Disabled-Transcript.log"
Start-Transcript -Path $LogFilePath

# Function to modify HKCU settings for all logged-in users
Function Invoke-HKCUChanges {
    $HKCURegistrySettings = @(
        @{
            Path = "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\NetDocuments.ndMail.OutlookAddIn";
            Name = "LoadBehavior";
            DesiredValue = 2
        }
    )

    # Get all loaded user profiles
    $UserSIDs = Get-ChildItem "HKU:\" | Where-Object { $_.PSChildName -notmatch "^S-1-5-(18|19|20)$" }

    foreach ($User in $UserSIDs) {
        foreach ($Setting in $HKCURegistrySettings) {
            $UserPath = $Setting["Path"] -replace "HKCU:", "HKU:\$($User.PSChildName)"
            $Name = $Setting["Name"]
            $DesiredValue = $Setting["DesiredValue"]

            try {
                # Check if the registry key exists for this user
                if (Test-Path -Path $UserPath) {
                    $CurrentValue = (Get-ItemProperty -Path $UserPath -Name $Name -ErrorAction Stop).$Name

                    # If the current value is not the desired value, update it
                    if ($CurrentValue -ne $DesiredValue) {
                        Set-ItemProperty -Path $UserPath -Name $Name -Value $DesiredValue
                        Write-Output "Updated HKCU LoadBehavior to Disabled for $UserPath to $DesiredValue."
                    } else {
                        Write-Output "HKCU LoadBehavior for $UserPath is already set to $DesiredValue."
                    }
                } else {
                    Write-Output "HKCU registry path $UserPath does not exist. Skipping."
                }
            } catch {
                Write-Output "An error occurred while processing $UserPath $($_.Exception.Message)"
            }
        }
    }
}

# Variables for HKLM registry paths, names, and desired values
$HKLMRegistrySettings = @(
    @{
        Path = "HKLM:\SOFTWARE\Microsoft\Office\Excel\Addins\MailSync";
        Name = "LoadBehavior";
        DesiredValue = 2
    },
    @{
        Path = "HKLM:\SOFTWARE\Microsoft\Office\Excel\Addins\NetDocuments.Client.ExcelAddIn";
        Name = "LoadBehavior";
        DesiredValue = 2
    },
    @{
        Path = "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\NetDocuments.ndMail.OutlookAddIn";
        Name = "LoadBehavior";
        DesiredValue = 2
    },
    @{
        Path = "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\NetDocuments.Client.OutlookAddIn";
        Name = "LoadBehavior";
        DesiredValue = 2
    },
    @{
        Path = "HKLM:\SOFTWARE\Microsoft\Office\PowerPoint\Addins\NetDocuments.Client.PowerPointAddIn";
        Name = "LoadBehavior";
        DesiredValue = 2
    },
    @{
        Path = "HKLM:\SOFTWARE\Microsoft\Office\Word\Addins\NetDocuments.Client.WordAddIn";
        Name = "LoadBehavior";
        DesiredValue = 2
    }
)

# Loop through each HKLM registry setting
foreach ($Setting in $HKLMRegistrySettings) {
    $Path = $Setting["Path"]
    $Name = $Setting["Name"]
    $DesiredValue = $Setting["DesiredValue"]

    try {
        # Check if the registry key exists
        if (Test-Path -Path $Path) {
            $CurrentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name

            # If the current value is not the desired value, update it
            if ($CurrentValue -ne $DesiredValue) {
                Set-ItemProperty -Path $Path -Name $Name -Value $DesiredValue
                Write-Output "Updated HKLM LoadBehavior to Disabled for $Path to $DesiredValue."
            } else {
                Write-Output "HKLM LoadBehavior for $Path is already set to $DesiredValue."
            }
        } else {
            Write-Output "HKLM registry path $Path does not exist. Skipping."
        }
    } catch {
        Write-Output "An error occurred while processing $Path $($_.Exception.Message)"
    }
}

# Apply changes to HKCU for all loaded user profiles
Invoke-HKCUChanges

Stop-Transcript
