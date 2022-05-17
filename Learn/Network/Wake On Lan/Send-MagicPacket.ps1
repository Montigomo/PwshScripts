
# WakeOnLan script



# function Send-MagicPacket
# {
# 	[CmdletBinding()]
# 	Param(
# 		[Parameter(Position=0, Mandatory=$true)]
# 		[string]$Mac,
# 		[Parameter(Position=1)]
# 		[object[]]$Ports = @(7, 9)
# 	)

# 	$BroadcastProxy=[System.Net.IPAddress]::Broadcast

# 	$synchronization = [byte[]](,0xFF * 6)
# 	$bmac = $Mac -Split ':' | ForEach-Object { [byte]('0x' + $_) }
# 	$packet = $synchronization + $bmac * 16
# 	$UdpClient = New-Object System.Net.Sockets.UdpClient
# 	$UdpClient.Client.EnableBroadcast = $true

# 	#$UdpClient = New-Object System.Net.Sockets.UdpClient
# 	foreach($port in $Ports)
# 	{
# 		$UdpClient = New-Object System.Net.Sockets.UdpClient
# 		$UdpClient.Connect($BroadcastProxy, $port)
# 		$UdpClient.Send($packet, $packet.Length) | Out-Null
# 		#$UdpClient.Send($packet, $packet.Length, $BroadcastProxy.IPAddressToString, $port) | Out-Null
# 		$UdpClient.Close()
# 	}
# 	#$UdpClient.Close()
# }

function Invoke-WakeOnLan
{
  param
  (
    # one or more MACAddresses
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    # mac address must be a following this regex pattern:
    [ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
    [string[]]
    $MacAddress 
  )
 
  begin
  {
    # instantiate a UDP client:
    $UDPclient = [System.Net.Sockets.UdpClient]::new()
  }
  process
  {
    foreach($_ in $MacAddress)
    {
      try {
        $currentMacAddress = $_
        
        # get byte array from mac address:
        $mac = $currentMacAddress -split '[:-]' |
          # convert the hex number into byte:
          ForEach-Object {
            [System.Convert]::ToByte($_, 16)
          }
 
        #region compose the "magic packet"
        
        # create a byte array with 102 bytes initialized to 255 each:
        $packet = [byte[]](,0xFF * 102)
        
        # leave the first 6 bytes untouched, and
        # repeat the target mac address bytes in bytes 7 through 102:
        6..101 | Foreach-Object { 
          # $_ is indexing in the byte array,
          # $_ % 6 produces repeating indices between 0 and 5
          # (modulo operator)
          $packet[$_] = $mac[($_ % 6)]
        }
        
        #endregion
        
        # connect to port 400 on broadcast address:
        $UDPclient.Connect(([System.Net.IPAddress]::Broadcast),4000)
        
        # send the magic packet to the broadcast address:
        $null = $UDPclient.Send($packet, $packet.Length)
        Write-Verbose "sent magic packet to $currentMacAddress..."
      }
      catch 
      {
        Write-Warning "Unable to send ${mac}: $_"
      }
    }
  }
  end
  {
    # release the UDF client and free its memory:
    $UDPclient.Close()
    $UDPclient.Dispose()
  }
}

$MacAdresses = @{
	AgiLaptopWiFi 	  = '34:f6:4b:b8:7b:ee'
	AgiDesktop		    = '74:d0:2b:a2:5c:45'
  NidalebLaptop	    = '54:a0:50:bc:29:70'
  NidalebLaptopWiFi = '54:27:1e:e4:62:57'
  SeanAdmin         = 'ac:e2:d3:65:6d:4c'
}

Invoke-WakeOnLan -MacAddress $MacAdresses["SeanAdmin"] -Verbose 

#Send-MagicPacket $MacAdresses["AgiDesktop"]
#Send-MagicPacket $MacAdresses["AgiLaptopWiFi"]