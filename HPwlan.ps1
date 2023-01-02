### HP-BIOS Set LAN/WLAN switching to Disable(needs reboot to intialize)
#Connect to the HP_BIOSSettingInterface WMI class
$Interface = Get-WmiObject -Namespace root\HP\InstrumentedBIOS -Class HP_BIOSSettingInterface
#Set a specific value for a specific setting when a BIOS password is set
$Interface.SetBIOSSetting("LAN / WLAN Auto Switching","Disable","<utf-16/>" + "0verland")





