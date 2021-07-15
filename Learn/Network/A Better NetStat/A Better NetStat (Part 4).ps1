

Install-Module -Name GetNetStat -Scope CurrentUser 

Get-NetStat -RemotePort 443 -State Established -Resolve | Select-Object -Property RemoteIp, Pid, PidName 