$xmlPath = "C:\ProgramData\Litera\customize\MetadactOutlookCustomize.xml"

# If the XML file is missing, consider it non-compliant
if (-Not (Test-Path $xmlPath)) {
    Write-Output "XML file not found: $xmlPath"
    exit 1
}

try {
    [xml]$xml = Get-Content $xmlPath -ErrorAction Stop
    $node = $xml.DocumentElement.SelectSingleNode("//AllowSkipAip")

    if ($null -eq $node) {
        Write-Output "The <AllowSkipAip> node does not exist."
        exit 1
    }

    $currentValue = $node.GetAttribute("INT_VALUE")

    if ($currentValue -eq "1") {
        Write-Output "The <AllowSkipAip> node exists and INT_VALUE is correctly set to 1."
        exit 0  # Compliant
    } else {
        Write-Output "The <AllowSkipAip> node exists but INT_VALUE is set to '$currentValue' instead of 1."
        exit 1  # Non-compliant
    }
}
catch {
    Write-Output "Error reading or parsing XML: $_"
    exit 1
}
