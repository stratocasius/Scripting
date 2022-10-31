# Set variables
    $source = Get-ChildItem -path "c:\" -Name "log4j-1.2*" -Recurse
    $Zippath = "C:\MOVE_HERE\"
    $DateTime = (Get-Date -Format "MM_yyyy")
    $exclude = @("*.zip")
    $files = Get-ChildItem -Path $path -Exclude $exclude
    $destination = Join-Path $path "$DateTime.zip"
    $7zip = "C:\Program Files\7-Zip\7z.exe"   

# Clear the screen
    cls

# Get source path
    $table = get-childitem -Path $source -Directory -Recurse | where-object {$_.CreationTime -lt (get-date).AddDays(-0)} 

foreach ($row in $table)                                          # for each folder in the folder, do this (loop)
{
    $move_row = Join-Path $source $row   
    $month_nm = $row.ToString().Substring(0,2)                    # use substring to get the 1st 2 digits(0,2) of each folder
    $year_nm = $row.ToString().Substring(4,4)                     # use substring to get the last 4 digits(4,4) of each folder
    $new_folder_nm = $month_nm+$year_nm                           # define new variable composed of the 1st 2 digits and last 4 digits
    $new_dest_path = Join-Path $path $new_folder_nm               # create the new folder in destination path

    If (!(Test-Path $new_dest_path))                              # test if the new folder exist, if not....
    {
        
        New-Item $new_dest_path -type directory                   # create the new folder

    }
    
# Actually create the archive
    dir $source $row -Recurse | Compress-Archive -DestinationPath $new_dest_path\$row.zip