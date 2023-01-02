# Establish and enforce coding rules
Set-StrictMode -Version 3

# When an error occurs, stop executing.
$ErrorActionPreference = 'Stop';

$DeploymentGroups = New-Object System.Collections.ArrayList

$DeploymentGroups.Add(@{
  ManageMSEdge = $true
  InternetExplorerIntegrationReloadInIEModeAllowed = $false
  ConfigureEnterpriseModeSiteList = ''
  MSEdgeRegistryTarget = 'Computer'
  MSEdgeLanguageId = 'enUS'
  InternetExplorerIntegrationCloudSiteList = 'cf09325a-5249-4370-b316-03979de63b6e'
  DeploymentType = 'GroupPolicy'
  ConfigureInternetExplorerIntegration = 'IEMode'
  GroupName = 'IE Mode for Edge'
}) | Out-Null

# -----------------------------------------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------------------------------

# Valid values for MSEdgeRegistryTarget
# Computer - HKEY_LOCAL_MACHINE will be updated
# User - HKEY_CURRENT_USER will be updated

# Valid values for ConfigureInternetExplorerIntegration
# IEIntegrationNotConfigured - Setting is not configured
# IE11 - Sites will open in a separate IE11 window
# IEMode - Sites will open in an IE Mode inside Microsoft Edge

# Download link for Policy Templates
$PolicyTemplatesUrl = 'https://go.microsoft.com/fwlink/?linkid=2145079'

# Collections to store objects created during the script for rolling back after errors
$PackagesCreated = New-Object System.Collections.ArrayList
$DeploymentPackagesCreated = New-Object System.Collections.ArrayList

$HasImportedArchiveModule = $false
function Import-ArchiveModule() {
    if ($HasImportedArchiveModule) {
        return
    }

    Write-Host 'Checking for Microsoft.PowerShell.Archive module'

    if (-not (Get-Module Microsoft.PowerShell.Archive)) {
        Write-Host 'Importing Microsoft.PowerShell.Archive module'
        Import-Module Microsoft.PowerShell.Archive | Out-Null
    }
    else {
        Write-Host 'Microsoft.PowerShell.Archive module already imported'
    }

    $HasImportedArchiveModule = $true
}

$HasImportedGroupPolicyModule = $false
function Import-GroupPolicyModule() {
    if ($HasImportedGroupPolicyModule) {
        return
    }

    Write-Host 'Checking if Group Policy PowerShell Module is installed'
    if ((Get-WindowsFeature GPMC).Installed -eq $false) {
        Write-Host 'Group Policy PowerShell Module is NOT installed'

        if (-not (IsUserRunningAsAdministrator)) {
            throw "You must run this script as administrator to install the Group Policy PowerShell Module"
        }

        Write-Host 'Installing Group Policy PowerShell Module'
        $Result = Install-WindowsFeature GPMC

        if (-not $Result.Success -or $Result.ExitCode -ne 'Success') {
            throw 'Installing Group Policy PowerShell Module was not successful. Cannot continue running script.'
        }

        if ($Result.RestartNeeded -eq 'Yes') {
            throw 'Installing Group Policy PowerShell Module was successful, but a reboot is required. Cannot continue running script.'
        }

        Write-Host 'Installing Group Policy PowerShell Module was successful'
    }
    else {
        Write-Host 'Group Policy PowerShell Module is installed'
    }

    Import-Module GroupPolicy

    $HasImportedGroupPolicyModule = $true
}

$HasImportedADModule = $false
function Import-ADModule() {
    if ($HasImportedADModule) {
        return
    }

    Write-Host 'Checking if Active Directory PowerShell Module is installed'
    if ((Get-WindowsFeature RSAT-AD-PowerShell).Installed -eq $false) {
        Write-Host 'Active Directory PowerShell Module is NOT installed'

        if (-not (IsUserRunningAsAdministrator)) {
            throw "You must run this script as administrator to install the Active Directory PowerShell Module"
        }

        Write-Host 'Installing Active Directory PowerShell Module'
        $Result = Install-WindowsFeature RSAT-AD-PowerShell

        if (-not $Result.Success -or $Result.ExitCode -ne 'Success') {
            throw 'Installing Active Directory PowerShell Module was not successful. Cannot continue running script.'
        }

        if ($Result.RestartNeeded -eq 'Yes') {
            throw 'Installing Active Directory PowerShell Module was successful, but a reboot is required. Cannot continue running script.'
        }

        Write-Host 'Installing Active Directory PowerShell Module was successful'
    }
    else {
        Write-Host 'Active Directory PowerShell Module is installed'
    }

    Import-Module ActiveDirectory

    $HasImportedADModule = $true
}

function IsUserRunningAsAdministrator() {
    $CurrentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = New-Object System.Security.Principal.WindowsPrincipal($CurrentIdentity)

    return $CurrentPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Confirm-SharePermissions($SharePath, $ParameterName, $AccountName, $MinimumPermissionNeeded) {
    Write-Host "Checking share permissions for parameter '$ParameterName' with value '$SharePath'"
    $UncParts = $SharePath.Split("\")
    $ServerName = $UncParts[2]
    $ShareName = $UncParts[3]

    Write-Host "ServerName = $ServerName"
    Write-Host "ShareName = $ShareName"

    if ($ServerName -eq $env:COMPUTERNAME) {
        $SharePermissions = Get-SmbShareAccess -Name $ShareName -ErrorAction Stop
    }
    else {
        $SharePermissions = Invoke-Command -ComputerName $ServerName -ErrorAction Stop -ScriptBlock {
            Get-SmbShareAccess -Name $using:ShareName -ErrorAction Stop
        }
    }

    if ($MinimumPermissionNeeded -eq 'Full') {
        $SharePermissions = $SharePermissions | Where-Object { $_.AccountName -eq $AccountName -and $_.AccessControlType -eq 'Allow' -and ($_.AccessRight -eq 'Full') }
    }
    elseif ($MinimumPermissionNeeded -eq 'Change') {
        $SharePermissions = $SharePermissions | Where-Object { $_.AccountName -eq $AccountName -and $_.AccessControlType -eq 'Allow' -and ($_.AccessRight -eq 'Full' -or $_.AccessRight -eq 'Change') }
    }
    elseif ($MinimumPermissionNeeded -eq 'Read') {
        $SharePermissions = $SharePermissions | Where-Object { $_.AccountName -eq $AccountName -and $_.AccessControlType -eq 'Allow' -and ($_.AccessRight -eq 'Full' -or $_.AccessRight -eq 'Change' -or $_.AccessRight -eq 'Read') }
    }
    else {
        throw '$MinimumPermissionNeeded must be one of these values: Read, Change or Full'
    }

    if (-not $SharePermissions -or $null -eq $SharePermissions) {
        $Option = ''
        while ($Option -ne 'Y' -and $Option -ne 'N' -and $Option -ne 'C') {
            Write-Host -ForegroundColor Yellow "The share for '$SharePath' does not allow $MinimumPermissionNeeded permission for the $AccountName account. Press 'Y' to grant $MinimumPermissionNeeded permission to the $AccountName account , press 'N' to abort, or press 'C' to continue."
            $Option = [System.Console]::ReadKey().Key
            Write-Host ""
        }

        if ($Option -eq 'Y') {
            Write-Host "Granting $MinimumPermissionNeeded permission to the $AccountName account for the share '$SharePath'."

            if ($ServerName -eq $env:COMPUTERNAME) {
                $CurrentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
                $CurrentPrincipal = New-Object System.Security.Principal.WindowsPrincipal($CurrentIdentity)

                if (-not $CurrentPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
                    throw "You must run this script as administrator to change share permissions on the local machine"
                }

                Grant-SmbShareAccess -Name $ShareName -AccountName $AccountName -AccessRight $MinimumPermissionNeeded -ErrorAction Stop -Confirm:$false
            }
            else {
                Invoke-Command -ComputerName $ServerName -ScriptBlock {
                    Grant-SmbShareAccess -Name $using:ShareName -AccountName $using:AccountName -AccessRight $using:MinimumPermissionNeeded -ErrorAction Stop -Confirm:$false
                }
            }
        }
        elseif ($Option -ne 'C') {
            throw "The share '$SharePath' does not allow $MinimumPermissionNeeded permission for the $AccountName account."
        }
    }
    else {
        Write-Host "The share '$SharePath' already has at least $MinimumPermissionNeeded permission for the $AccountName account."
    }
}

function Confirm-ScriptExecution() {
    $Option = ''
    while ($Option -ne 'Y' -and $Option -ne 'N') {
        Write-Host -ForegroundColor Yellow "This script is intended for IT professionals. It will create a new Group Policy Object and configure settings in a healthy and stable Group Policy environment. Press 'Y' to continue running this script. Press 'N' to exit."
        $Option = [System.Console]::ReadKey().Key
        Write-Host ""
    }
    if ($Option -eq 'Y') {
        Start-Deployment
    }
    elseif ($Option -eq 'N') {
        throw "Exiting script"
    }
}

function Confirm-Arguments($DeploymentGroup) {
    Write-Host "Validating arguments"

    $DeploymentGroup.MSEdgeLanguageId = $DeploymentGroup.MSEdgeLanguageId.Insert(2, '-')
 
    # GroupName
    if ($DeploymentGroup.GroupName -eq '') {
        throw '$DeploymentGroup.GroupName cannot be blank'
    }

    # ManageMSEdge
    if ($DeploymentGroup.ManageMSEdge -eq $false) {
        throw '$DeploymentGroup.ManageMSEdge cannot be $false'
    }

    # MSEdgeRegistryTarget
    if ($DeploymentGroup.MSEdgeRegistryTarget -ne 'Computer' -and $DeploymentGroup.MSEdgeRegistryTarget -ne 'User') {
        throw '$DeploymentGroup.MSEdgeRegistryTarget must be one of these values: Computer or User'
    }

    # Validate arguments specific to ManageMSEdge
    if ($DeploymentGroup.ManageMSEdge -eq $true) {
        # ActionToTakeOnStartup

        # ConfigureInternetExplorerIntegration
        if ($DeploymentGroup.ConfigureInternetExplorerIntegration -ne 'IEIntegrationNotConfigured' `
                -and $DeploymentGroup.ConfigureInternetExplorerIntegration -ne '' `
                -and $DeploymentGroup.ConfigureInternetExplorerIntegration -ne 'IE11' `
                -and $DeploymentGroup.ConfigureInternetExplorerIntegration -ne 'IEMode') {
            throw '$DeploymentGroup.ConfigureInternetExplorerIntegration must be one of these values: IEIntegrationNotConfigured, IE11, or IEMode'
        }

        # ConfigureEnterpriseModeSiteList

        if ($DeploymentGroup.ConfigureEnterpriseModeSiteList -ne '' -and $DeploymentGroup.ConfigureEnterpriseModeSiteList -notlike '\\*\*') {
            throw '$DeploymentGroup.ConfigureEnterpriseModeSiteList must be in UNC format: \\servername\sharename\path'
        }

        if ($DeploymentGroup.ConfigureEnterpriseModeSiteList -ne '' -and $DeploymentGroup.ConfigureEnterpriseModeSiteList -notlike '*.xml') {
            throw '$DeploymentGroup.ConfigureEnterpriseModeSiteList must end in .xml'
        }

    }
}

function Get-IsLanguageIDValid($LanguageID) {
    if ($LanguageID -eq 'MatchOS') {
        return $true
    }

    try {
        [System.Globalization.CultureInfo]::new($LanguageID)
        return $true
    }
    catch {
    }

    return $false
}

function Get-Domain() {
    Write-Host "Getting Active Directory domain"
    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain
    Write-Host "Domain is $Domain"
    return $Domain
}

function Get-MsiDownloadUrl($DeploymentGroup) {
    if ($DeploymentGroup.OSArchitecture -eq 'Bit64') {
        return $MicrosoftEdge64BitUrl
    }
    else {
        return $MicrosoftEdge32BitUrl
    }
}

function Get-MsiFilePathForGroupPolicy($DeploymentGroup) {
    if ($DeploymentGroup.OSArchitecture -eq 'Bit64') {
        return Join-Path -Path $DeploymentGroup.MSINetworkPath -ChildPath $MicrosoftEdge64BitFileName
    }
    else {
        return Join-Path -Path $DeploymentGroup.MSINetworkPath -ChildPath $MicrosoftEdge32BitFileName
    }
}

function Install-EdgeInstallFiles($DeploymentGroup, $MsiFilePath) {
    $MsiDownloadUrl = Get-MsiDownloadUrl -DeploymentGroup $DeploymentGroup

    Write-Host 'Disabling Download Progress Bar For Performance Reasons'
    $ProgressPreference = 'SilentlyContinue'

    Write-Host "Downloading Microsoft Edge Install package to $MsiFilePath."
    Invoke-WebRequest -Uri $MsiDownloadUrl -OutFile ('filesystem::' + $MsiFilePath)

    Write-Host 'Enabling Download Progress Bar'
    $ProgressPreference = 'Continue'
}

function Install-EdgeManagementTemplates($DeploymentGroup) {
    Write-Host "Generating temp file name for Microsoft Edge policy templates package download"
    $PolicyTemplatesFilePath = (New-TemporaryFile).FullName
    $ExtractFolderPath = $PolicyTemplatesFilePath
    Remove-Item $PolicyTemplatesFilePath
    $PolicyTemplatesFilePath = $PolicyTemplatesFilePath + '.cab'

    Write-Host 'Disabling Download Progress Bar For Performance Reasons'
    $ProgressPreference = 'SilentlyContinue'

    Write-Host "Downloading Microsoft Edge policy templates package to $PolicyTemplatesFilePath."
    Invoke-WebRequest -Uri $PolicyTemplatesUrl -OutFile ('filesystem::' + $PolicyTemplatesFilePath)
    $DownloadFolderPath = (Get-Item $PolicyTemplatesFilePath).Directory.FullName

    Write-Host 'Enabling Download Progress Bar'
    $ProgressPreference = 'Continue'

    Write-Host "Expanding Microsoft Edge policy templates package"
    expand.exe -R $PolicyTemplatesFilePath

    Write-Host "Extracting Microsoft Edge policy templates package to $ExtractFolderPath."
    Expand-Archive -LiteralPath (Join-Path -Path $DownloadFolderPath -ChildPath 'MicrosoftEdgePolicyTemplates.zip') -DestinationPath $ExtractFolderPath

    $Domain = Get-Domain
    $PolicyDefinitionsPath = "\\$Domain\sysvol\$Domain\Policies\PolicyDefinitions"
    Write-Host "Checking for PolicyDefinitions folder at $PolicyDefinitionsPath"
    if (Test-Path -LiteralPath $PolicyDefinitionsPath) {
        Write-Host "$PolicyDefinitionsPath already exists"
    }
    else {
        Write-Host "Creating folder $PolicyDefinitionsPath"
        New-Item -Path $PolicyDefinitionsPath -ItemType "directory" | Out-Null
    }

    $PolicyDefinitionsLanguagePath = Join-Path -Path $PolicyDefinitionsPath -ChildPath $DeploymentGroup.MSEdgeLanguageId
    Write-Host "Checking for $($DeploymentGroup.MSEdgeLanguageId) folder at $PolicyDefinitionsLanguagePath"
    if (Test-Path -LiteralPath $PolicyDefinitionsLanguagePath) {
        Write-Host "$PolicyDefinitionsLanguagePath already exists"
    }
    else {
        Write-Host "Creating folder $PolicyDefinitionsLanguagePath"
        New-Item -Path $PolicyDefinitionsLanguagePath -ItemType "directory" | Out-Null
    }

    $ADMXSourceFilePath = Join-Path -Path $ExtractFolderPath -ChildPath "windows\admx\msedge.admx"
    $ADMXDestinationFilePath = $PolicyDefinitionsPath
    Write-Host "Moving $ADMXSourceFilePath to $ADMXDestinationFilePath"
    Copy-Item -Path $ADMXSourceFilePath -Destination $ADMXDestinationFilePath

    $ADMLSourceFilePath = Join-Path -Path $ExtractFolderPath -ChildPath "windows\admx\$($DeploymentGroup.MSEdgeLanguageId)\msedge.adml"
    $ADMLDestinationFilePath = $PolicyDefinitionsLanguagePath
    Write-Host "Moving $ADMLSourceFilePath to $ADMLDestinationFilePath"
    Copy-Item -Path $ADMLSourceFilePath -Destination $ADMLDestinationFilePath
}

# function Install-DeploymentToolsForGroupPolicy($DeploymentGroup) {
#
#    if ($DeploymentGroup.ManageMSEdge) {
#        Install-EdgeManagementTemplates -DeploymentGroup $DeploymentGroup
#    }
# }

# function Install-DeploymentTools($DeploymentGroup) {
#    if ($DeploymentGroup.DeploymentType -eq 'GroupPolicy') {
# Install-DeploymentToolsForGroupPolicy -DeploymentGroup $DeploymentGroup
#    }
# }

# function Uninstall-DeploymentTools($DeploymentGroup) {
#    if ($DeploymentGroup.DeploymentType -eq 'ConfigurationManager') {
#        Write-Host "Removing IETelemetry namespace from WMI"
#        Get-WmiObject -Query "Select * From __Namespace where Name='IETelemetry'" -Namespace "root/CIMV2" | Remove-WmiObject
#    }
#    elseif ($DeploymentGroup.DeploymentType -eq 'GroupPolicy') {
#    }
# }

function New-ClientInstallationForGroupPolicy($DeploymentGroup) {
    Write-Host "Creating new group policy object: $($DeploymentGroup.GroupName)"
    $Domain = Get-Domain
    $GPO = New-GPO -Domain $Domain -Name $DeploymentGroup.GroupName

    if (-not $GPO) {
        throw "Could not create group policy object: $($DeploymentGroup.GroupName)"
    }

    if ($DeploymentGroup.MSEdgeRegistryTarget -eq 'Computer') {
        $RegistryTarget = 'HKEY_LOCAL_MACHINE'
        $ApplicationsFolderName = "Machine"
    }
    elseif ($DeploymentGroup.MSEdgeRegistryTarget -eq 'User') {
        $RegistryTarget = 'HKEY_CURRENT_USER'
        $ApplicationsFolderName = "User"
    }

    if ($DeploymentGroup.ManageMSEdge) {
                
        if ($DeploymentGroup.ConfigureInternetExplorerIntegration -ne 'IEIntegrationNotConfigured' -and $DeploymentGroup.ConfigureInternetExplorerIntegration -ne '') {
            Write-Host 'Updating group policy object to configure ConfigureInternetExplorerIntegration'

            if ($DeploymentGroup.ConfigureInternetExplorerIntegration -eq 'IE11') {
                $ConfigureInternetExplorerIntegration = 2
            }
            elseif ($DeploymentGroup.ConfigureInternetExplorerIntegration -eq 'IEMode') {
                $ConfigureInternetExplorerIntegration = 1
            }

            $GPO | Set-GPRegistryValue -Key $RegistryTarget'\Software\Policies\Microsoft\Edge' -ValueName 'InternetExplorerIntegrationLevel' -Value $ConfigureInternetExplorerIntegration -Type DWord | Out-Null
        }

        if ($DeploymentGroup.ConfigureEnterpriseModeSiteList -ne '') {
            Write-Host 'Updating group policy object to configure ConfigureEnterpriseModeSiteList'
            $GPO | Set-GPRegistryValue -Key $RegistryTarget'\Software\Policies\Microsoft\Edge' -ValueName 'InternetExplorerIntegrationSiteList' -Value $DeploymentGroup.ConfigureEnterpriseModeSiteList -Type String | Out-Null
        }

        if ($DeploymentGroup.InternetExplorerIntegrationCloudSiteList -ne '') {
            Write-Host 'Updating group policy object to configure InternetExplorerIntegrationCloudSiteList'
            $GPO | Set-GPRegistryValue -Key $RegistryTarget'\Software\Policies\Microsoft\Edge' -ValueName 'InternetExplorerIntegrationCloudSiteList' -Value $DeploymentGroup.InternetExplorerIntegrationCloudSiteList -Type String | Out-Null
        }

        if ($DeploymentGroup.InternetExplorerIntegrationReloadInIEModeAllowed) {
            Write-Host 'Updating group policy object to configure InternetExplorerIntegrationReloadInIEModeAllowed'
            $GPO | Set-GPRegistryValue -Key $RegistryTarget'\Software\Policies\Microsoft\Edge' -ValueName 'InternetExplorerIntegrationReloadInIEModeAllowed' -Value 1 -Type DWord | Out-Null
        }

    }
}

function Start-DeploymentForDeploymentGroup($DeploymentGroup) {
    #    Install-DeploymentTools -DeploymentGroup $DeploymentGroup

    New-ClientInstallationForGroupPolicy -DeploymentGroup $DeploymentGroup
}

function Start-Deployment() {
    try {
        if (-not (IsUserRunningAsAdministrator)) {
            $WaitTime = 5

            Write-Warning "You do not have Administrator rights to run this script."
            Write-Warning "Launching a new powershell process as Administrator in $WaitTime seconds..."

            Start-Sleep -Seconds $WaitTime

            $Arguments = '-File "' + $PSCommandPath + '"'

            Start-Process "powershell" -Verb RunAs -ArgumentList $Arguments

            return
        }

        Write-Host "Enabling TLS 1.2 for this PowerShell session"
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

        Import-ArchiveModule

        foreach ($DeploymentGroup in $DeploymentGroups) {
            Write-Host "Current deployment type is $($DeploymentGroup.DeploymentType)"

            if ($DeploymentGroup.DeploymentType -eq 'GroupPolicy') {
                Import-GroupPolicyModule
                Import-ADModule
            }

            Confirm-Arguments -DeploymentGroup $DeploymentGroup

            Start-DeploymentForDeploymentGroup -DeploymentGroup $DeploymentGroup
        }

        Write-Host "All deployment groups successfully created"
    }
    catch {
        Write-Host 'Exception thrown' -ForegroundColor Red
        $OriginalColor = $host.ui.RawUI.ForegroundColor
        $host.ui.RawUI.ForegroundColor = 'Red'
        $_
        $host.ui.RawUI.ForegroundColor = $OriginalColor

        Remove-CMObjects
    }
    finally {
        #        Uninstall-DeploymentTools -DeploymentGroup $DeploymentGroup
    }

    Write-Host "Press any key to continue"
    [System.Console]::ReadKey() | Out-Null
}

Confirm-ScriptExecution
