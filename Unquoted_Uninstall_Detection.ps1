$ExportedCSV = "C:\windows\temp\unquoted-search-path-changes.csv"
If(test-path $ExportedCSV)
{Exit 0}
else {EXIT 1}