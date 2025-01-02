# Bail out if we aren't in OOBE
$TypeDef = @" 
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
  
namespace Api
{
 public class Kernel32
 {
   [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
   public static extern int OOBEComplete(ref int bIsOOBEComplete);
 }
}
"@ 
Add-Type -TypeDefinition $TypeDef -Language CSharp
  
$IsOOBEComplete = $false
$hr = [Api.Kernel32]::OOBEComplete([ref] $IsOOBEComplete)
if ($IsOOBEComplete) {
  Write-Host "Not in OOBE, nothing to do."
  exit 0
}
 
# Get device information
$systemEnclosure = Get-CimInstance -ClassName Win32_SystemEnclosure
$details = Get-ComputerInfo
 
# Get the new computer name: use the asset tag (maximum of 13 characters), or the 
# serial number if no asset tag is available (replace this logic if you want)
if (($null -eq $systemEnclosure.SMBIOSAssetTag) -or ($systemEnclosure.SMBIOSAssetTag -eq "")) {
    # Stupid PowerShell 5.1 bug
    if ($null -ne $details.BiosSerialNumber) {
        $assetTag = $details.BiosSerialNumber
    } else {
        $assetTag = $details.BiosSeralNumber
    }
} else {
    $assetTag = $systemEnclosure.SMBIOSAssetTag
}
if ($assetTag.Length -gt 13) {
    $assetTag = $assetTag.Substring(0, 13)
}
if ($details.CsPCSystemTypeEx -eq 1) {
    $newName = "D-$assetTag"
} else {
    $newName = "L-$assetTag"
}
 
# Is the computer name already set?  If so, bail out
if ($newName -ieq $details.CsName) {
    Write-Host "No need to rename computer, name is already set to $newName"
    Exit 0
}
 
# Set the computer name
Write-Host "Renaming computer to $($newName)"
Rename-Computer -NewName $newName -Force