#--------------------------------------------
# Detect-DisablePstAllUsers.ps1
#--------------------------------------------

# Collect any remediation-needed entries
$results = @()

# Enumerate loaded user SIDs via PSChildName (skip Classes hives)
Get-ChildItem -Path 'Registry::HKEY_USERS' |
  Where-Object {
    $sid = $_.PSChildName
    ($sid -match '^S-1-5-21-') -and ($sid -notmatch '_Classes$')
  } |
  ForEach-Object {
    $sid         = $_.PSChildName
    $pathOutlook = "Registry::HKEY_USERS\$sid\Software\Policies\Microsoft\office\16.0\outlook"
    $pathPst     = "$pathOutlook\pst"

    $val1 = (Get-ItemProperty -LiteralPath $pathOutlook -Name 'disablepst'     -ErrorAction SilentlyContinue).disablepst
    $val2 = (Get-ItemProperty -LiteralPath $pathPst     -Name 'pstdisablegrow' -ErrorAction SilentlyContinue).pstdisablegrow

    if ($val1 -eq 1 -or $val2 -eq 1) {
        $results += "[$sid] disablepst=$val1; pstdisablegrow=$val2"
    }
}

if ($results.Count -gt 0) {
    # Join all entries with “ | ”, append remediation flag, write as one line
    $line = ($results -join ' | ') + ' | remediation required'
    Write-Output $line
    exit 1
}
else {
    Write-Output "pst policies not set or set to 0 for all users; No remediation needed"
    exit 0
}