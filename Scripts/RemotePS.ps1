<#

192.168.1.100
192.168.1.101

Enable-PSRemoting -Force
Set-WSManQuickConfig

Set-Item wsman:\localhost\client\trustedhosts 81.200.243.64
Set-Item wsman:\localhost\client\trustedhosts 128.68.223.185
Set-Item wsman:\localhost\client\trustedhosts *

Test-WsMan 128.68.223.185

$password = ConvertTo-SecureString "nidaleb45" -AsPlainText -Force
$cred= New-Object System.Management.Automation.PSCredential ("username", $password )

Enter-PSSession -ComputerName 128.68.223.185 -Credential nidaleb
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