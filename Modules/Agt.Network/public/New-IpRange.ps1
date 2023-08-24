function New-IpRange {
  param
  (
    [Parameter(Mandatory)]
    [ipaddress]
    $From,
    
    [Parameter(Mandatory)]
    [ipaddress]
    $To
  )
  
  $ipFromBytes = $From.GetAddressBytes()
  $ipToBytes = $To.GetAddressBytes()
  
  # change endianness (reverse bytes)
  [array]::Reverse($ipFromBytes)
  [array]::Reverse($ipToBytes)
  
  # convert reversed bytes to uint32
  $start = [BitConverter]::ToUInt32($ipFromBytes, 0 )
  $end = [BitConverter]::ToUInt32($ipToBytes, 0 )
  
  # enumerate from start to end uint32
  for ($x = $start; $x -le $end; $x++) {
    # split uit32 back into bytes
    $ip = [bitconverter]::getbytes($x)
    # reverse bytes back to normal
    [Array]::Reverse($ip)
    # output ipv4 address as string
    $ip -join '.'
  } 
}