# Define task scheduler path
$TaskPath = "\Microsoft\Windows\EnterpriseMgmt"

# List all tasks
$TaskList = schtasks.exe /Query /FO LIST /V

# Split the output into an array of lines
$Lines = $TaskList -split "`n"

# Initialize an empty hash table for the current task
$CurrentTask = @{}

# Initialize an empty array for all UUIDs
$UUIDs = @()

# Process each line
foreach ($Line in $Lines) {
    # Trim leading and trailing whitespace
    $Line = $Line.Trim()

    # If the line is empty, it means we've finished processing the current task
    if ($Line -eq "") {
        # If the current task's path matches the target path, add the UUID to the UUIDs array
        if ($CurrentTask["Folder"] -like "*$TaskPath*") {
            # Extract UUID from the Folder string and add to the UUIDs array
            if ($CurrentTask["Folder"] -match '[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}') {
                $UUIDs += $Matches[0]
            }
        }

        # Clear the current task
        $CurrentTask = @{}

        # Skip to the next line
        continue
    }

    # Split the line into a name-value pair
    $Pair = $Line -split ":", 2

    # Trim leading and trailing whitespace from the name and value
    $Name = $Pair[0].Trim()
    $Value = $Pair[1].Trim()

    # Add the name-value pair to the current task
    $CurrentTask[$Name] = $Value
}

# Output the UUIDs
$UUIDs | ForEach-Object { Write-Output $_ }
