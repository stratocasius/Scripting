$OUTPUT= [System.Windows.Forms.MessageBox]::Show("Please Logoff to allow important updates to begin.                                             Select YES to logoff now, or NO to logoff at another time. Thank you, JL IT." , "***JL IT - Log Off for Updates***" , 4) 

if ($OUTPUT -eq "YES" ) 
{

cmd /c logoff


} 
else 
{ 
..do something else 
} 

