# Define registry key path
New-PSDrive -Name "HKCR" -PSProvider Registry -Root "HKEY_CLASSES_ROOT"

$RegPath = "HKCR:\.pdf"
$ExpectedValue = "PowerPDF.Document"

try {
    $actual = (Get-Item -Path $RegPath -ErrorAction Stop).GetValue("", $null)

    if ($actual -eq $ExpectedValue) {
        Write-Output "Compliant: (Default) is set to '$ExpectedValue'."
        exit 0
    } else {
        Write-Output "Non-compliant: (Default) is '$actual' instead of '$ExpectedValue'."
        exit 1
    }
}
catch {
    Write-Output "Non-compliant: Key not found or error accessing registry. $_"
    exit 1
}
