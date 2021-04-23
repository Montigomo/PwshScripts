
#function Get-
$process = @{
  Name = 'ProcessName'
  Expression = { (Get-Process -Id $_.OwningProcess).Name }
}
 
$darkAgent = @{
  Name = 'ExternalIdentity'
  Expression = { 
    $ip = $_.RemoteAddress 
    (Invoke-RestMethod -Uri "http://ipinfo.io/$ip/json" -UseBasicParsing -ErrorAction Ignore).org
  
  }
}
Get-NetTCPConnection -RemotePort 443 -State Established |
  Select-Object -Property RemoteAddress, OwningProcess, $process, $darkAgent 