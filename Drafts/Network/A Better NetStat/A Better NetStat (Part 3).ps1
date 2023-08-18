

# get all connections to port 443 (HTTPS)
Get-NetTCPConnection -RemotePort 443 -State Established | 
  # where there is a remote address
  Where-Object RemoteAddress |
  # start parallel processing here
  # create a loop that runs with 80 consecutive threads
  ForEach-Object -ThrottleLimit 80 -Parallel {
      # $_ now represents one of the results emitted
      # by Get-NetTCPConnection
      $remoteHost = $_.RemoteAddress
      # DNS resolution occurs now in separate threads
      # at the same time
      $hostname = try { 
                    # try to resolve IP address
                    [Net.Dns]::GetHostEntry($remoteHost). HostName
                  } catch {
                    # if that fails, return IP anyway
                    $remoteHost
                  }
      # compose the calculated information into one object
      [PSCustomObject]@{
        HostName = $hostname
        OwningProcess = $_.OwningProcess
        Process = (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Path
      }
  } 