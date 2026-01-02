$xmlPath = "C:\ProgramData\Litera\customize\MetadactOutlookCustomize.xml"
$logPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\MetadactRemediation.log"

# Function to write to log
function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logPath -Append -Force
}

# Exit early if file is missing
if (-Not (Test-Path $xmlPath)) {
    Write-Log "XML file not found at $xmlPath. No remediation applied."
    Write-Output "XML file not found at $xmlPath. No remediation applied."
    exit 1
}

try {
    [xml]$xml = Get-Content $xmlPath -ErrorAction Stop
    $root = $xml.DocumentElement

    $node = $root.SelectSingleNode("//AllowSkipAip")

    if ($node) {
        $currentValue = $node.GetAttribute("INT_VALUE")
        if ($currentValue -ne "1") {
            $node.SetAttribute("INT_VALUE", "1")
            $xml.Save($xmlPath)
            Write-Log "<AllowSkipAip> INT_VALUE was '$currentValue'. Updated to '1'."
            Write-Output "<AllowSkipAip> INT_VALUE was '$currentValue'. Updated to '1'."
        } else {
            Write-Log "<AllowSkipAip> INT_VALUE already set to '1'. No changes made."
            Write-Output "<AllowSkipAip> INT_VALUE already set to '1'. No changes made."
        }
    } else {
        # Node doesn't exist — create and append it
        $newNode = $xml.CreateElement("AllowSkipAip")
        $newNode.SetAttribute("INT_VALUE", "1")
        $root.AppendChild($newNode) | Out-Null
        $xml.Save($xmlPath)
        Write-Output "<AllowSkipAip> node was missing. Added new node with INT_VALUE='1'."
    }
}
catch {
    Write-Log "Remediation failed with error: $_"
    exit 1
}

exit 0