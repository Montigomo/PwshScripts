
Import-Module NetSecurity

#turn on off windows firewall
#Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False



# Ultra Vnc rules

#New-NetFirewallRule -Name "Uvnc_Service" -DisplayName “Unvc Service” -Description “Uvnc Service” -Program "C:\Program Files\uvnc bvba\UltraVNC\winvnc.exe" -Protocol TCP -Profile Any -Action Allow -Enabled True

# tightvnc
New-NetFirewallRule -Name TightVNC -DisplayName "TightVNC Service" -Description "TightVNC Service" -Program "C:\Program Files\TightVNC\tvnserver.exe" -Enabled True -Profile Any -Action Allow 