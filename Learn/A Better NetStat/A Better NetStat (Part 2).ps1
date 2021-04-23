

$Process = @{
    Name='Process'
    Expression={
        # return process path
        (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Path
     
        }
}
 
$HostName = @{
    Name='Host'
    Expression={
        $remoteHost = $_.RemoteAddress
        try { 
            # try to resolve IP address
            [Net.Dns]::GetHostEntry($remoteHost).HostName
        } catch {
            # if that fails, return IP anyway
            $remoteHost
        }
    }
}
 
# get all connections to port 443 (HTTPS)
Get-NetTCPConnection -RemotePort 443 -State Established | 
  # where there is a remote address
  Where-Object RemoteAddress |
  # and resolve IP and process ID
  Select-Object -Property $HostName, OwningProcess, $Process 