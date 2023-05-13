


$Process = @{
    Name='Process'
    Expression={
        # return process path
        (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Path
    }
}
 
$IpOwner = @{
    Name='RemoteAuthority'
    Expression={
        $ip = $_.RemoteAddress
        $info = Invoke-RestMethod -Uri "http://ipinfo.io/$ip/json"
        '{0} ({1})' -f $info.Org, $info.City
    }
}
 
# get all connections to port 443 (HTTPS)
Get-NetTCPConnection -RemotePort 443 -State Established | 
  # where there is a remote address
  Where-Object RemoteAddress |
  # and resolve IP and Process ID
  Select-Object -Property $IPOwner, RemoteAddress, OwningProcess, $Process  