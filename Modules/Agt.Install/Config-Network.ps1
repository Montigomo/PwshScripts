


#enable file printer sharing 

Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Disable-NetFirewallRule

Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Enable-NetFirewallRule