


netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

netsh advfirewall firewall set rule group=”network discovery” new enable=yes

netsh firewall set service type=fileandprint mode=enable profile=all

Get-NetFirewallRule -DisplayGroup 'Network discovery' | Set-NetFirewallRule -Profile 'Private, Domain' -Enabled true

Get-NetFirewallRule -DisplayGroup 'Обнаружение сети' | Set-NetFirewallRule -Profile 'Private, Domain' -Enabled true