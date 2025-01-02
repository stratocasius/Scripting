# Check if the file exists
$licenseFilePath = "C:\ProgramData\Levit & James, Inc\Best Authority.NET\BestAuthority.License.xml"
$logFilePath = "C:\Windows\Temp\BA-License.log"

if (Test-Path $licenseFilePath) {
    Write-Output "License file already exists at $licenseFilePath. Exiting script." | Out-File -FilePath $logFilePath -Append
} else {
    # XML content to be written
    $xmlContent = @"
<!--WARNING WARNING WARNING
This file has been digitally signed
by a Levit & James application. If
you modify it by any other means
(such as by editing it with Notepad)
then you will no longer be able to
use it with your Levit & James
software.-->
<LJLicense xmlns:lj="urn:ljlicensing">
  <CheckSum>
    <Format>0</Format>
    <LicenseKey>F81F-4707-7AF1-F739-A1BD-455B-CD12-8D41-37FD-BC23-2ADE-274A</LicenseKey>
  </CheckSum>
  <License>
    <CustomerName>Jackson Lewis, P.C.</CustomerName>
    <Product>
      <Name>Best Authority</Name>
      <Edition>Premium</Edition>
    </Product>
    <Data>
      <LicenseCount>619</LicenseCount>
      <LicenseDescription>619 Litigators</LicenseDescription>
      <EvaluationLicense>False</EvaluationLicense>
      <LicenseIssuedDate>September 08, 2015</LicenseIssuedDate>
      <LicenseExpirationDate>December 31, 2999</LicenseExpirationDate>
      <SubscriptionExpirationDate>September 01, 2016</SubscriptionExpirationDate>
      <SerialNumber>LI-BA-150908-002</SerialNumber>
      <Flags />
    </Data>
  </License>
  <BestAuthority>
  </BestAuthority>
</LJLicense>
"@

    # Create the directory if it doesn't exist
    $directory = Split-Path $licenseFilePath
    if (-not (Test-Path -Path $directory)) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }

    # Write XML content to file
    $xmlContent | Out-File -FilePath $licenseFilePath

    # Write output to log file
    Write-Output "License file created at $licenseFilePath" | Out-File -FilePath $logFilePath -Append
}
