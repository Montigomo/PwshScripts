

# --- Private Networks
# -- Network discovery
netsh advfirewall firewall set rule group=”network discovery” new enable=yes
# -- File and printer sharing
netsh firewall set service type=fileandprint mode=enable profile=all


# --- Public Networks
# -- Network discovery

# -- File and printer sharing


# --- All networks
# -- Public folder sharing


# -- Password Protection Sharing  
# 0 - turn off  1 - turn on
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'RestrictNullSessAccess' -Value '0'
# anonymous access 0 - disable ; 1 - enable
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'everyoneincludesanonymous' -Value '1'
# quest account
net user guest /active:yes
