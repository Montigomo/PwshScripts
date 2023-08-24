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