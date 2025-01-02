<root>
    <entry>
        <name>Global Protect Enforcer Transport Filter V4</name>
        <filterKey>Value1</filterKey>
    </entry>
    <entry>
        <name>Entry2</name>
        <filterKey>Value2</filterKey>
    </entry>
    <!-- More entries -->
</root>



# Create the filter.xml
& cmd /c "netsh wfp show filters"
# Path to your XML file
$xmlPath = "C:\Windows\Temp\filters.txt"

# Load the XML file
[xml]$xmlContent = Get-Content -Path $xmlPath

# Define the name you want to search for
$searchName = "Global Protect Enforcer Filter"  # Replace with the name you want to search for

# Find the entry with the specific name
$entry = $xmlContent.root.entry | Where-Object { $_.name -eq $searchName }

if ($entry -ne $null) {
    # Get the filterKey value
    $filterKeyValue = $entry.filterKey

    # Write the filterKey value to a text file
    $outputFilePath = "C:\Windows\Temp\PA-Enforcement-Filter.txt"  # Replace with your desired output file path
    $filterKeyValue | Out-File -FilePath $outputFilePath
    Write-Host "FilterKey value '$filterKeyValue' written to $outputFilePath."
} else {
    Write-Host "Entry '$searchName' not found in the XML."
}
