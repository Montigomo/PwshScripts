function Send-MagicPacket
{
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
 
  [CmdletBinding()]
 
  Param
  (
    [Parameter(Mandatory=$true,ParameterSetName = "Set1")][string]$DHCPServerName, 
    [Parameter(Mandatory=$true,ParameterSetName = "Set1")][string]$ComputerName,
    [Parameter(Mandatory=$true,ParameterSetName = "Set2")][string]$MACAddress,
    [Parameter(Mandatory=$true,ParameterSetName = "Set2")][string]$BroadcastAddress
  )
       
  $mac = $null
  $broadcast = $null
     
  #формируем значение MAC- и широковещательного адреса для отправки "магического" пакета
     
  if ($MACAddress -eq [string]::Empty -and $BroadcastAddress |
    -eq [string]::Empty) #значения получаем от DHCP-сервера
  {
    #формируем текстовые значения ip- и mac-адреса, а также маски подсети
         
    $ip = (Resolve-DnsName -Name $ComputerName -Type A).IPAddress
    $lease = Get-DhcpServerv4Lease -ComputerName $DHCPServerName -IPAddress $ip
    $mac = $lease.ClientID.Replace('-','')
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
  else #значения задаем вручную
  {
    $mac = $MACAddress
    $broadcast = $BroadcastAddress
  }
     
  #формируем "магический пакет"
      
  $target=0,2,4,6,8,10 | ForEach-Object {[convert]::ToByte($mac.substring($_,2),16)} 
  $packet = (,[byte]255 * 6) + ($target * 16)
     
  #отправляем "магический пакет"
     
  $udp_client = new-Object System.Net.Sockets.UdpClient
  $udp_client.Client.EnableBroadcast = $true
  $udp_client.Send($packet, 102, $broadcast, 9) | Out-Null
  Write-Host Магический пакет с MAC-адресом $mac отправлен на широковещательный адрес $broadcast
}