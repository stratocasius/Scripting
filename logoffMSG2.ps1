Add-type –AssemblyName System.Windows.Forms
$OUTPUT= [System.Windows.Forms.MessageBox]::Show("Please Logoff to allow important updates to begin.                                             Select YES to logoff now, or NO to logoff at another time. Thank you, JL IT." , "***JL IT - Log Off for Updates***" , 4) 

if ($OUTPUT -eq "YES" ) 
{

cmd /c logoff


} 
else 
{ 

[System.Windows.Forms.MessageBox]::Show("Please Log Off when possible to recieve updates- thanks" , "***JL IT - Log Off for Updates***" , 0)

} 

