
# WakeOnLan script

function Send-MagicPacket
{
	[CmdletBinding()]
	Param(
		[Parameter(Position=0, Mandatory=$true)]
		[string]$Mac,
		[Parameter(Position=1)]
		[object[]]$Ports = @(7, 9)
	)
	$BroadcastProxy=[System.Net.IPAddress]::Broadcast
	#$Ports = 7,9

	$synchronization = [byte[]](,0xFF * 6)
	$bmac = $Mac -Split ':' | ForEach-Object { [byte]('0x' + $_) }
	$packet = $synchronization + $bmac * 16
	$UdpClient = New-Object System.Net.Sockets.UdpClient
	$UdpClient.Client.EnableBroadcast = $true

	#$UdpClient = New-Object System.Net.Sockets.UdpClient
	foreach($port in $Ports)
	{
		$UdpClient = New-Object System.Net.Sockets.UdpClient
		$UdpClient.Connect($BroadcastProxy, $port)
		$UdpClient.Send($packet, $packet.Length) | Out-Null
		#$UdpClient.Send($packet, $packet.Length, $BroadcastProxy.IPAddressToString, $port) | Out-Null
		$UdpClient.Close()
	}
	#$UdpClient.Close()
}


$MacAdresses = @{
	AgiLaptopWiFi	= '34:f6:4b:b8:7b:ee'
	AgiDesktop		= '74:d0:2b:a2:5c:45'
}



Send-MagicPacket $MacAdresses["AgiDesktop"]
Send-MagicPacket $MacAdresses["AgiLaptopWiFi"]