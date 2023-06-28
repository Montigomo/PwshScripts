
[CmdletBinding()]
param (
  [Parameter()]
  [ValidateSet("Agitech", "Sean")]
  [string]$NetToScan
)

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

function Get-PrinterInfo {
  param
  (
    [Parameter(Mandatory)]
    [string]
    $ComputerName
  )
    
  $oid = @{
    RAW_DATA                         = ".1.3.6.1.2.1.43.18.1.1"
    CONSOLE_DATA                     = ".1.3.6.1.2.1.43.16"
    CONTACT                          = ".1.3.6.1.2.1.1.4.0"
    LOCATION                         = ".1.3.6.1.2.1.1.6.0"
    SERIAL_NUMBER                    = ".1.3.6.1.2.1.43.5.1.1.17.1"
    SYSTEM_DESCRIPTION               = ".1.3.6.1.2.1.1.1.0"
    DEVICE_DESCRIPTION               = ".1.3.6.1.2.1.25.3.2.1.3.1"
    DEVICE_STATE                     = ".1.3.6.1.2.1.25.3.2.1.5.1"
    DEVICE_ERRORS                    = ".1.3.6.1.2.1.25.3.2.1.6.1"
    UPTIME                           = ".1.3.6.1.2.1.1.3.0"
    MEMORY_SIZE                      = ".1.3.6.1.2.1.25.2.2.0"
    PAGE_COUNT                       = ".1.3.6.1.2.1.43.10.2.1.4.1.1"
    HARDWARE_ADDRESS                 = ".1.3.6.1.2.1.2.2.1.6.1"
    TRAY_1_NAME                      = ".1.3.6.1.2.1.43.8.2.1.13.1.1"
    TRAY_1_CAPACITY                  = ".1.3.6.1.2.1.43.8.2.1.9.1.1"
    TRAY_1_LEVEL                     = ".1.3.6.1.2.1.43.8.2.1.10.1.1"
    TRAY_2_NAME                      = ".1.3.6.1.2.1.43.8.2.1.13.1.2"
    TRAY_2_CAPACITY                  = ".1.3.6.1.2.1.43.8.2.1.9.1.2"
    TRAY_2_LEVEL                     = ".1.3.6.1.2.1.43.8.2.1.10.1.2"
    TRAY_3_NAME                      = ".1.3.6.1.2.1.43.8.2.1.13.1.3"
    TRAY_3_CAPACITY                  = ".1.3.6.1.2.1.43.8.2.1.9.1.3"
    TRAY_3_LEVEL                     = ".1.3.6.1.2.1.43.8.2.1.10.1.3"
    TRAY_4_NAME                      = ".1.3.6.1.2.1.43.8.2.1.13.1.4"
    TRAY_4_CAPACITY                  = ".1.3.6.1.2.1.43.8.2.1.9.1.4"
    TRAY_4_LEVEL                     = ".1.3.6.1.2.1.43.8.2.1.10.1.4"
    BLACK_TONER_CARTRIDGE_NAME       = ".1.3.6.1.2.1.43.11.1.1.6.1.1"
    BLACK_TONER_CARTRIDGE_CAPACITY   = ".1.3.6.1.2.1.43.11.1.1.8.1.1"
    BLACK_TONER_CARTRIDGE_LEVEL      = ".1.3.6.1.2.1.43.11.1.1.9.1.1"
    CYAN_TONER_CARTRIDGE_NAME        = ".1.3.6.1.2.1.43.11.1.1.6.1.2"
    CYAN_TONER_CARTRIDGE_CAPACITY    = ".1.3.6.1.2.1.43.11.1.1.8.1.2"
    CYAN_TONER_CARTRIDGE_LEVEL       = ".1.3.6.1.2.1.43.11.1.1.9.1.2"
    MAGENTA_TONER_CARTRIDGE_NAME     = ".1.3.6.1.2.1.43.11.1.1.6.1.3"
    MAGENTA_TONER_CARTRIDGE_CAPACITY = ".1.3.6.1.2.1.43.11.1.1.8.1.3"
    MAGENTA_TONER_CARTRIDGE_LEVEL    = ".1.3.6.1.2.1.43.11.1.1.9.1.3"
    YELLOW_TONER_CARTRIDGE_NAME      = ".1.3.6.1.2.1.43.11.1.1.6.1.4"
    YELLOW_TONER_CARTRIDGE_CAPACITY  = ".1.3.6.1.2.1.43.11.1.1.8.1.4"
    YELLOW_TONER_CARTRIDGE_LEVEL     = ".1.3.6.1.2.1.43.11.1.1.9.1.4"
    WASTE_TONER_BOX_NAME             = ".1.3.6.1.2.1.43.11.1.1.6.1.5"
    WASTE_TONER_BOX_CAPACITY         = ".1.3.6.1.2.1.43.11.1.1.8.1.5"
    WASTE_TONER_BOX_LEVEL            = ".1.3.6.1.2.1.43.11.1.1.9.1.5"
    BELT_UNIT_NAME                   = ".1.3.6.1.2.1.43.11.1.1.6.1.6"
    BELT_UNIT_CAPACITY               = ".1.3.6.1.2.1.43.11.1.1.8.1.6"
    BELT_UNIT_LEVEL                  = ".1.3.6.1.2.1.43.11.1.1.9.1.6"
    BLACK_DRUM_UNIT_NAME             = ".1.3.6.1.2.1.43.11.1.1.6.1.7"
    BLACK_DRUM_UNIT_CAPACITY         = ".1.3.6.1.2.1.43.11.1.1.8.1.7"
    BLACK_DRUM_UNIT_LEVEL            = ".1.3.6.1.2.1.43.11.1.1.9.1.7"
    CYAN_DRUM_UNIT_NAME              = ".1.3.6.1.2.1.43.11.1.1.6.1.8"
    CYAN_DRUM_UNIT_CAPACITY          = ".1.3.6.1.2.1.43.11.1.1.8.1.8"
    CYAN_DRUM_UNIT_LEVEL             = ".1.3.6.1.2.1.43.11.1.1.9.1.8"
    MAGENTA_DRUM_UNIT_NAME           = ".1.3.6.1.2.1.43.11.1.1.6.1.9"
    MAGENTA_DRUM_UNIT_CAPACITY       = ".1.3.6.1.2.1.43.11.1.1.8.1.9"
    MAGENTA_DRUM_UNIT_LEVEL          = ".1.3.6.1.2.1.43.11.1.1.9.1.9"
    YELLOW_DRUM_UNIT_NAME            = ".1.3.6.1.2.1.43.11.1.1.6.1.10"
    YELLOW_DRUM_UNIT_CAPACITY        = ".1.3.6.1.2.1.43.11.1.1.8.1.10"
    YELLOW_DRUM_UNIT_LEVEL           = ".1.3.6.1.2.1.43.11.1.1.9.1.10"
  }
    
  # connect to printer:
  $SNMP = New-Object -ComObject olePrn.OleSNMP
  $SNMP.Open($ComputerName, 'public')
    
  $hash = [Ordered]@{}
  $hash['IPAddress'] = $ComputerName
    
  $oid.Keys | 
  Sort-Object |
  ForEach-Object {
    $hash[$_] = try { $SNMP.Get($oid[$_]) } catch { '<NOINFO>' }
  }
    
  $SNMP.Close()
    
  [PSCustomObject]$hash
} 

function Test-RemotePort {
  param
  (
    [Parameter(Mandatory)]
    [int]
    $Port ,
    [string]
    $ComputerName = $env:COMPUTERNAME,
    [int ]
    $TimeoutMilliSec = 1000
  )
    
  try {
    $client = [Net.Sockets.TcpClient]:: new()
    $task = $client.ConnectAsync($ComputerName , $Port)
    if ($task.Wait($TimeoutMilliSec )) {
      $success = $client.Connected 
    }
    else {
      $success = $false 
    }
  }
  catch { $success = $false }
  finally {
    $client.Close()
    $client. Dispose()
  }
    
  [ PSCustomObject]@{
    ComputerName = $ComputerName
    Port         = $Port
    Response     = $success
  }
}

function Test-Ping {
  param
  (
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]
    $ComputerName,
    [int]
    $TimeoutMillisec = 1000,
    [switch]
    $ResolveHostName
  )
    
  begin {
    $pinger = [Net.NetworkInformation.Ping]::new() 
  }
  process {
    $ComputerName | 
    ForEach-Object {
      $ip = $_
      $pinger.Send($_, $TimeoutMillisec) |
      Select-Object -Property Status, Address , ComputerName |
      ForEach-Object {
        # add the property "computername" which stores the user input
        $_.ComputerName = $ip
        $_
      }
    }
  }
  end {
    $pinger.Dispose()
  }
}

#Install-Module -Name PSParallel -Scope CurrentUser 
#Install-Module -Name ImportExcel

function ScanLanPrinters {
  # Test-RemotePort -ComputerName 192.168.0.220 -Port 9100 -TimeoutMilliSec 1000
  # Get-PrinterInfo -ComputerName 192.168.0.220
  # Test-RemotePort -ComputerName 192.168.0.110 -Port 9100 -TimeoutMilliSec 1000

  # Get-PrinterInfo -ComputerName 192.168.1.140

  New-IpRange -From 192.168.0.1 -To 192.168.0.255 | ForEach-Object { Test-RemotePort -ComputerName $_ -Port 9100 -TimeoutMilliSec 1000 } | Select-Object -Property ComputerName, Port, Response | Where-Object Response #| Get-PrinterInfo -ComputerName $_.ComputerName  | Export-Excel

  #New-IpRange -From 192.168.0.1 -To 192.168.0.255 | Invoke-Parallel { Test-RemotePort -ComputerName $_ -Port 9100 -TimeoutMilliSec 1000 } -ThrottleLimit 128 | Where-Object Response | Invoke-Parallel { Get-PrinterInfo -ComputerName $_.ComputerName }

  #New-IpRange -From 192.168.1.1 -To 192.168.1.255 | Invoke-Parallel { Test-RemotePort -ComputerName $_ -Port 9100 -TimeoutMilliSec 1000 } -ThrottleLimit 128 | Where-Object Response | Invoke-Parallel { Get-PrinterInfo -ComputerName $_.ComputerName }
}

function SeanScan {

  New-IpRange -From 192.168.0.1 -To 192.168.0.255 | Invoke-Parallel { Test-Ping -ComputerName $_ -TimeoutMilliSec 500 } -ThrottleLimit 128 | Where-Object { $_.Status -eq "Succes" } `
  | Invoke-Parallel { 
    try {
      $_.ComputerName = [System.Net.DNS]::GetHostEntry($_.ComputerName).HostName ; $_ 
    }
    catch {
      $t = 0;
    }
  } -ThrottleLimit 128 `
  | Select-Object -Property Status, Address, ComputerName, Name | Format-Table -Wrap -AutoSize
  #New-IpRange -From 192.168.0.1 -To 192.168.0.255 | Invoke-Parallel { Test-RemotePort -ComputerName $_ -Port 22 -TimeoutMilliSec 1000 } -ThrottleLimit 128  | Where-Object { $_.Response } | Select-Object -Property ComputerName, Port, Response | Format-Table -Wrap -AutoSize

}

switch ($NetToScan) {
  "Sean" {
    SeanScan
    break
  }
  Default{
    SeanScan
    break
  }
}


exit