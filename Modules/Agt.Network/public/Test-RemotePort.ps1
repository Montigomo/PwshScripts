function Test-RemotePort {
  param
  (
    [Parameter(Mandatory)][int]$Port ,
    [string]$ComputerName = $env:COMPUTERNAME,
    [int]$TimeoutMilliSec = 1000
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
    $ip4address = $client.Client.RemoteEndPoint.Address.MapToIPv4();
  }
  catch { $success = $false }
  finally {
    $client.Close()
    $client. Dispose()
  }
    
  [ PSCustomObject]@{
    Address      = $ip4address
    ComputerName = $ComputerName
    Port         = $Port
    Response     = $success
  }
}