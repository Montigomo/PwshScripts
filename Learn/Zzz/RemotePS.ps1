<#
1. 
Enable-PSRemoting -Force
Set-WSManQuickConfig
2. 
Set-Item wsman:\localhost\client\trustedhosts 81.200.243.64
Set-Item wsman:\localhost\client\trustedhosts 128.68.219.89:280
Set-Item wsman:\localhost\client\trustedhosts *
3.
Test-WsMan 128.68.223.185

$password = ConvertTo-SecureString "nidaleb45" -AsPlainText -Force
$cred= New-Object System.Management.Automation.PSCredential ("username", $password )

128.68.219.89
Enter-PSSession -ComputerName 128.68.219.89 -Credential nidaleb@outlook.com
//nidaleb45


$newtab = $psise.powershelltabs.Add()
$newtab.Invoke("Enter-PSSession -computername 128.68.223.185 -Credential nidaleb")

$newtab = $psise.powershelltabs.Add()
$newtab.Invoke("Enter-PSSession -computername 192.168.1.101 -Credential nidaleb")

---- Private Public connections

$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}")) 
$connections = $networkListManager.GetNetworkConnections() 

# Set network location to Private for all networks 
$connections | % {$_.GetNetwork().SetCategory(1)}

---- Firewall rules

Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -RemoteAddress Any








#>

foreach ($loopnumber in 1..8){
    Start-Job -ScriptBlock{
    $result = 1
        foreach ($number in 1..2147483647){
            $result = $result * $number
        }# end foreach
    }# end Start-Job
}# end foreach