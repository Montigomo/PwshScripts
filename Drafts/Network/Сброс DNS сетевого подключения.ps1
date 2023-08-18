
Add-Type -AssemblyName PresentationFramework

#$Logfile = "$PSScriptRoot\log.log"

$sources = get-netadapter | Select-Object -Property  Name, InterfaceIndex;

$adapterName = ($sources | Out-GridView -Title 'Выберете сетевой адаптер' -OutputMode Single).InterfaceIndex

if($adapterName){

    #Set-DnsClientServerAddress -InterfaceIndex $adapterName  -ServerAddresses ("10.0.0.1","10.0.0.2")
    Set-DnsClientServerAddress -InterfaceIndex $adapterName  -ResetServerAddresses
}
exit
