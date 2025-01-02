# Function to check and set power settings
function Set-PowerSettings {
    # Check and set standby timeout for on battery
    $standbyTimeoutDC = powercfg /query standby-timeout-ac
    if ($standbyTimeoutDC -notlike '*15 minutes*') {
        powercfg /change standby-timeout-dc 15
        Add-Content -Path 'C:\Windows\temp\PowerConfig-Settings.log' -Value "Changed standby-timeout-dc to 15 minutes"
    }

    # Check and set standby timeout for plugged in
    $standbyTimeoutAC = powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE
    if ($standbyTimeoutAC -notlike '*0 minutes*') {
        powercfg /change standby-timeout-ac 0
        Add-Content -Path 'C:\Windows\temp\PowerConfig-Settings.log' -Value "Changed standby-timeout-ac to 15 minutes"
    }

    # Check and set hibernate timeout for on battery
    $hibernateTimeoutDC = powercfg /query SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE
    if ($hibernateTimeoutDC -notlike '*30 minutes*') {
        powercfg /change standby-timeout-dc 30
        Add-Content -Path 'C:\Windows\temp\PowerConfig-Settings.log' -Value "Changed hibernate-timeout-dc to 30 minutes"
    }

    # Check and set hibernate timeout for plugged in
    $hibernateTimeoutAC = powercfg /query SCHEME_CURRENT SUB_BUTTONS UIBUTTON_ACTION
    if ($hibernateTimeoutAC -notlike '*0 minutes*') {
        powercfg /change sleep-timeout-ac 0
        Add-Content -Path 'C:\Windows\temp\PowerConfig-Settings.log' -Value "Changed hibernate-timeout-ac to 0 minutes"
    }
}

# Run the function to set power settings
Set-PowerSettings

#####################################################################################################

# Get the current active power plan
$activePlan = powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE

# Set the display timeout (in seconds)
$displayTimeoutInSeconds = 900  # Change this value as needed
powercfg /change standby-timeout-ac $displayTimeoutInSeconds
powercfg /change standby-timeout-dc $displayTimeoutInSeconds

# Apply the changes to the active power plan
powercfg /setactive $activePlan
###################################################################################


# Define the log file path
$logFilePath = "C:\Windows\Temp\PowerSettingsApp-INSTALL.log"
# Set the display timeout (in seconds) for AC
$displayTimeoutAC = 15  # Change this value as needed
powercfg /change monitor-timeout-ac $displayTimeoutAC
     # Log the changes to the log file
     Add-Content -Path $logFilePath -Value "$(Get-Date) - Power plan settings updated to timeout display after [15] minutes of inactivity on AC power."

# Set the display timeout (in seconds) for DC
$displayTimeoutDC = 15  # Change this value as needed
powercfg /change monitor-timeout-dc $displayTimeoutDC
     # Log the changes to the log file
     Add-Content -Path $logFilePath -Value "$(Get-Date) - Power plan settings updated to timeout display after [15] minutes of inactivity on DC power."

# Set the sleep timeout (in seconds) for AC
$SleepTimeoutAC = 0  # Change this value as needed
powercfg /change standby-timeout-ac $SleepTimeoutAC
     # Log the changes to the log file
     Add-Content -Path $logFilePath -Value "$(Get-Date) - Power plan Sleep settings updated to 0 mins [Never] timeout the OS while plugged in(AC)."

# Set the sleep timeout (in seconds) for DC
$SleepTimeoutDC = 30  # Change this value as needed
powercfg /change standby-timeout-dc $SleepTimeoutDC
     # Log the changes to the log file
     Add-Content -Path $logFilePath -Value "$(Get-Date) - Power plan Sleep settings updated to [30] minutes of inactivity to timeout the OS on battery(DC)."

     ### Create app detection
New-Item -Path HKCU:\Software\Intune
New-ItemProperty -Path HKCU:\Software\Intune -Name Remediation_Win11PowerPlanSetting -Type String -Value 01252024 -Force

###################################################################################

# Define the log file path
$logFilePath = "C:\Windows\Temp\SleepSettings-INSTALL.log"

# Define the registry paths for power settings
$batterySleepPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\381b4222-f694-41f0-9685-ff5bb260df2e\238c9fa8-0aad-41ed-83f4-97be242c8f20\29f6c1db-86da-48c5-9fdb-f2b67b1f44da\238c9fa8-0aad-41ed-83f4-97be242c8f20"
$pluggedInSleepPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\381b4222-f694-41f0-9685-ff5bb260df2e\238c9fa8-0aad-41ed-83f4-97be242c8f20\29f6c1db-86da-48c5-9fdb-f2b67b1f44da\6fe69556-704a-47a0-8f24-c28d936fda47\94ac6d29-73ce-41a6-809f-6363d69659e9"

# Function to check and update sleep settings in the registry
function Update-RegistrySleepSettings {
    # Check if registry settings need to be updated
    $sleepOnBattery = (Get-ItemProperty -Path $batterySleepPath -Name Attributes).Attributes -eq 1
    $doNothingPluggedIn = (Get-ItemProperty -Path $pluggedInSleepPath -Name Attributes).Attributes -eq 2

    if (-not $sleepOnBattery -or -not $doNothingPluggedIn) {
        # Set the registry settings for sleep on battery
        Set-ItemProperty -Path $batterySleepPath -Name Attributes -Value 1

        # Set the registry settings for 'Do nothing' when plugged in
        Set-ItemProperty -Path $pluggedInSleepPath -Name Attributes -Value 2

        # Log the changes to the log file
        Add-Content -Path $logFilePath -Value "$(Get-Date) - Registry sleep settings updated."

        Write-Host "Registry sleep settings updated and logged to $logFilePath"
    } else {
        # Log that no changes were made
        Add-Content -Path $logFilePath -Value "$(Get-Date) - Registry sleep settings already configured."

        Write-Host "Registry sleep settings already configured. No changes made."
    }
}

# Run the function to check and update registry sleep settings
Update-RegistrySleepSettings
