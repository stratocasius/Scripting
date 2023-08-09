# Get the root folder of the task scheduler
$rootFolder = Get-ScheduledTask -TaskPath '\'

# Function to recursively retrieve all tasks and their properties
function Get-Tasks($folder) {
    foreach ($task in $folder.Tasks) {
        # Retrieve task properties
        $taskName = $task.Path
        $taskState = $task.State
        $taskLastRunTime = $task.LastRunTime
        $taskNextRunTime = $task.NextRunTime
        $taskUUID = $task.Settings.TaskGuid

        # Print the task details
        Write-Host "Task Name: $taskName"
        Write-Host "UUID: $taskUUID"
        Write-Host "State: $taskState"
        Write-Host "Last Run Time: $taskLastRunTime"
        Write-Host "Next Run Time: $taskNextRunTime"
        Write-Host "-------------------"

        # Recursively retrieve tasks within subfolders
        Get-Tasks -folder $task.Subtasks
    }
}

# Call the Get-Tasks function on the root folder
Get-Tasks -folder $rootFolder
