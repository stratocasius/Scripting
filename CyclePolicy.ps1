$hostlist = @($Input)

if($($hostlist.length) -gt 0){
    foreach ($srv in $hostlist) {

        # Binding \\$srv\root\ccm:SMS_Client
        $SMSCli = [wmiclass] "\\$srv\root\ccm:SMS_Client"

        if($SMSCli){

            #Invoking $actionName 
            $check = $SMSCli.RequestMachinePolicy()
            $check = $SMSCli.EvaluateMachinePolicy()
        }
        else{
            write-host "$srv, Could not bind WMI class SMS_Client"
        }
    }
}
