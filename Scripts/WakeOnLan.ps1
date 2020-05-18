
#$Mac='01-2C-34-4C-1C-12'
$Mac   = '74:d0:2b:a2:5c:45'
$MacBL = "54:A0:50:BC:29:70"

$BroadcastProxy=[System.Net.IPAddress]::Broadcast
$Ports = 7,9

$synchronization = [byte[]](,0xFF * 6)
$bmac = $Mac -Split ':' | ForEach-Object { [byte]('0x' + $_) }
$packet = $synchronization + $bmac * 16

$UdpClient = New-Object System.Net.Sockets.UdpClient

foreach($port in $Ports) {
	$UdpClient.Connect($BroadcastProxy, $port)
    $UdpClient.Send($packet, $packet.Length) | Out-Null
	}

$UdpClient.Close()
