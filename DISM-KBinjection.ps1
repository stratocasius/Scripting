dism /Mount-Wim /WimFile:<path_to_install.wim> /MountDir:<mount_directory> /Index:<index_number>
dism /Add-Package /Image:D:\mount /PackagePath:C:\Users\vaultadmin\Downloads\windows11.0-kb5035853-x64_8ca1a9a646dbe25c071a8057f249633a61929efa.msu
dism /Unmount-Wim /MountDir:<mount_directory> /Commit

Confirm before/after
dism /Mount-Wim /WimFile:<path_to_install.wim> /MountDir:<mount_directory> /Index:<index_number>
dism /Image:<mount_directory> /Get-Packages
dism /Unmount-Wim /MountDir:<mount_directory> /Commit

ndOffice 3.4.2.
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{7530d6f4-cf3f-4bc9-a230-1b81c04da623}
DisaplyVersion - 3.4.2.20018
Assoc with 32 - YES!
