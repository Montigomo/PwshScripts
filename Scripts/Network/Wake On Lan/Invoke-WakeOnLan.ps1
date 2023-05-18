
# WakeOnLan script

function Send-MagicPacket_Method3 {
  <#
  .SYNOPSIS
  Командлет предназначен для удаленного включения компьютеров посредством Wake-On-Lan
  .DESCRIPTION
  Командлет отправляет "магический пакет", содержащий MAC-адрес сетевого адаптера 
  компьютера, на широковещательный адрес подсети, к которой он принадлежит
  "Магический пакет" может формироваться с использованием следующих наборов параметров:
  - MAC-адрес сетевого адаптера и широковещательный адрес подсети
  - имя DHCP-сервера и имя "пробуждаемого" компьютера (MAC-адрес и широковещательный 
  адрес будут определены на основании данных об аренде IP-адреса на DHCP-сервере)
  .PARAMETER MACAddress
  MAC-адрес сетевого адаптера компьютера
  .PARAMETER BroadcastAddress
  Широковещательный адрес подсети, к которой принадлежит компьютер
  .PARAMETER DHCPServerName
  Имя DHCP-сервера
  .PARAMETER ComputerName
  Имя "пробуждаемого" компьютера
  .INPUTS
  -
  .OUTPUTS
  -    
  .NOTES
  (c) 2018 Александр Галков, alexander@galkov.pro
  .EXAMPLE
  Send-MagicPacket -DHCPServerName dc.domain.local -ComputerName galkov.domain.local
  .EXAMPLE
  Send-MagicPacket -MACAddress 0a1b2c3d4e5f -BroadcastAddress 10.100.200.255
  .LINK
  www.galkov.pro/powershell_script_for_turning_on_computers_using_wol
  #>
  # Enabling WOL from BIOS (Power by PCI-PCIE)
  # Disabling fast boot from both Windows 10 and BIOS
  # Enabling Magic Packet in device manager
  # Disabling "allow the computer to turn off this device for the ethernet adapter" after enabling both options for "allow this device to wake the computer".
  [CmdletBinding()]
 
  Param
  (
    [Parameter(Mandatory = $true, ParameterSetName = "Set1")]
    [string]$DHCPServerName, 
    [Parameter(Mandatory = $true, ParameterSetName = "Set1")]
    [string]$ComputerName,
    [Parameter(Mandatory = $true, ParameterSetName = "Set2")]
    [string]$MACAddress,
    [Parameter(Mandatory = $true, ParameterSetName = "Set2")]
    [string]$BroadcastAddress
  )
       
  $mac = $null
  $broadcast = $null
     
  #формируем значение MAC- и широковещательного адреса для отправки "магического" пакета
     
  if ($MACAddress -eq [string]::Empty -and $BroadcastAddress |
    -eq [string]::Empty) { #значения получаем от DHCP-сервера
    #формируем текстовые значения ip- и mac-адреса, а также маски подсети
         
    $ip = (Resolve-DnsName -Name $ComputerName -Type A).IPAddress
    $lease = Get-DhcpServerv4Lease -ComputerName $DHCPServerName -IPAddress $ip
    $mac = $lease.ClientID.Replace('-', '')
    $scope = Get-DhcpServerv4Scope -ComputerName $DHCPServerName -ScopeId $lease.ScopeId
    $mask = $scope.SubnetMask.IPAddressToString
         
    #формируем текстовое значение широковещательного адреса подсети
         
    [uint32]$ip_numb = ([IPAddress]$ip).Address
    [uint32]$mask_numb = ([IPAddress]$mask).Address
    $subnet_numb = $ip_numb -band $mask_numb
    $inv_mask_numb = -bnot $mask_numb
    $broadcast_numb = $subnet_numb -bor $inv_mask_numb
    $broadcast = ([IPAddress]$broadcast_numb).IPAddressToString
  }
  else { #значения задаем вручную
    $mac = $MACAddress
    $broadcast = $BroadcastAddress
  }
     
  #формируем "магический пакет"
      
  $target = 0, 2, 4, 6, 8, 10 | ForEach-Object { [convert]::ToByte($mac.substring($_, 2), 16) } 
  $packet = (, [byte]255 * 6) + ($target * 16)
     
  #отправляем "магический пакет"
     
  $udp_client = new-Object System.Net.Sockets.UdpClient
  $udp_client.Client.EnableBroadcast = $true
  $udp_client.Send($packet, 102, $broadcast, 9) | Out-Null
  Write-Host "Магический пакет с MAC-адресом $mac отправлен на широковещательный адрес $broadcast"
}

function Send-MagicPacket_Method2 {
  <# 
  .SYNOPSIS  
    Send a WOL packet to a broadcast address
  .PARAMETER mac
   The MAC address of the device that need to wake up
  .PARAMETER ip
   The IP address where the WOL packet will be sent to
  .EXAMPLE 
   Send-WOL -mac 00:11:32:21:2D:11 -ip 192.168.8.255 
#>

  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]$mac,
    [string]$ip = "255.255.255.255", 
    [int]$port = 9
  )
  $broadcast = [Net.IPAddress]::Parse($ip)
 
  $mac = (($mac.replace(":", "")).replace("-", "")).replace(".", "")
  $target = 0, 2, 4, 6, 8, 10 | % { [convert]::ToByte($mac.substring($_, 2), 16) }
  $packet = (, [byte]255 * 6) + ($target * 16)
 
  $UDPclient = new-Object System.Net.Sockets.UdpClient
  $UDPclient.Connect($broadcast, $port)
  [void]$UDPclient.Send($packet, 102) 

}

function Send-MagicPacket_Method1 {
  [CmdletBinding()]
  Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Mac,
    [Parameter(Position = 1)]
    [object[]]$Ports = @(7, 9)
  )

  $BroadcastProxy = [System.Net.IPAddress]::Broadcast

  $synchronization = [byte[]](, 0xFF * 6)
  $bmac = $Mac -Split ':' | ForEach-Object { [byte]('0x' + $_) }
  $packet = $synchronization + $bmac * 16
  $UdpClient = New-Object System.Net.Sockets.UdpClient
  $UdpClient.Client.EnableBroadcast = $true

  #$UdpClient = New-Object System.Net.Sockets.UdpClient
  foreach ($port in $Ports) {
    $UdpClient = New-Object System.Net.Sockets.UdpClient
    $UdpClient.Connect($BroadcastProxy, $port)
    $UdpClient.Send($packet, $packet.Length) | Out-Null
    #$UdpClient.Send($packet, $packet.Length, $BroadcastProxy.IPAddressToString, $port) | Out-Null
    $UdpClient.Close()
  }
  #$UdpClient.Close()
}

function Send-MagicPacket_Method0 {
  param
  (
    # one or more MACAddresses
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    # mac address must be a following this regex pattern:
    [ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
    [string[]]
    $MacAddress 
  )
 
  begin {
    # instantiate a UDP client:
    $UDPclient = [System.Net.Sockets.UdpClient]::new()
  }
  process {
    foreach ($_ in $MacAddress) {
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
        $packet = [byte[]](, 0xFF * 102)
        
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
        $UDPclient.Connect(([System.Net.IPAddress]::Broadcast), 4000)
        
        # send the magic packet to the broadcast address:
        $null = $UDPclient.Send($packet, $packet.Length)
        Write-Verbose "sent magic packet to $currentMacAddress..."
      }
      catch {
        Write-Warning "Unable to send ${mac}: $_"
      }
    }
  }
  end {
    # release the UDF client and free its memory:
    $UDPclient.Close()
    $UDPclient.Dispose()
  }
}

$Items = @{
  AgiLaptop         = @{MAC = '60:a4:4c:06:34:b2'; Port = 9 }
  NidalebLaptop     = @{MAC = '54:a0:50:bc:29:70'; Port = 9 }
  SeanAdmin         = 'ac:e2:d3:65:6d:4c'
}

Send-MagicPacket_Method0 -MacAddress $Items["NidalebLaptop"]["MAC"] -Verbose
Send-MagicPacket_Method0 -MacAddress $Items["AgiLaptop"]["MAC"] -Verbose
