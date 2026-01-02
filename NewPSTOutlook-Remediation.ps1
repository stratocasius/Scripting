#--------------------------------------------
# Remediate-DisablePstAllUsers.ps1
#--------------------------------------------

# Enumerate loaded user SIDs via PSChildName
$regUsers = Get-ChildItem -Path 'Registry::HKEY_USERS' |
  Where-Object {
    $sid = $_.PSChildName
    ($sid -match '^S-1-5-21-') -and ($sid -notmatch '_Classes$')
  }

foreach ($hive in $regUsers) {
    $sid         = $hive.PSChildName
    $pathOutlook = "Registry::HKEY_USERS\$sid\Software\Policies\Microsoft\office\16.0\outlook"
    $pathPst     = "$pathOutlook\pst"

    foreach ($p in @($pathOutlook, $pathPst)) {
        if (-not (Test-Path -LiteralPath $p)) {
            New-Item -Path $p -Force | Out-Null
        }
    }

    New-ItemProperty -LiteralPath $pathOutlook -Name 'disablepst'     -PropertyType DWord -Value 0 -Force | Out-Null
    New-ItemProperty -LiteralPath $pathPst     -Name 'pstdisablegrow' -PropertyType DWord -Value 0 -Force | Out-Null
}

Write-Output "disablepst and pstdisablegrow set to 0 for all loaded user hives"
exit 0
