function Test-Ping {
  param
  (
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]
    $ComputerName,
        
    [int]
    $TimeoutMillisec = 1000
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