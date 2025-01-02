### Litera Metadact Customize Folder Remediation - 06/25/2024
### Define the source and destination paths
$destinationPath = "C:\Programdata\Litera\Customize"

# Copy the contents from the source to the G:\
Remove-Item -Path "C:\Programdata\Litera\Customize" -Recurse -Force -Verbose  
New-Item -ItemType Directory -path "C:\Programdata\Litera\Customize" -Force
Copy-Item -Path "\\jacksonlewis.net\shares\Software\Litera Software\customize\Customize.xml" -Destination $destinationPath -Recurse -Force
Write-Output "Files were successfully copied to $destinationPath."