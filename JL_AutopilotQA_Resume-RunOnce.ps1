$runOncePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
$name = "JL_AutopilotQA_Resume"
 
$uri = "ms-powerautomate:/console/flow/run?environmentid=Default-6ab77482-4dda-43b3-9e50-82db3e426c2c&workflowid=c30efcaf-2772-4d50-8cb4-51eed25ccd94&source=Other"
 
$cmd = "powershell.exe -WindowStyle Hidden -Command `"Start-Process '$uri'`""
 
if (-not (Test-Path $runOncePath)) {
    New-Item -Path $runOncePath -Force | Out-Null
}
 
New-ItemProperty -Path $runOncePath -Name $name -Value $cmd -PropertyType String -Force | Out-Null
 
"RunOnce set (hidden launch)."