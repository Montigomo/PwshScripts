


Import-Module NetSecurity



New-NetFirewallRule -Name YAWC_Service -DisplayName “YAWC Service” -Description “YAWC Service” -Program "C:\Program Files (x86)\Yawcam\Yawcam_Service.exe" -RemoteAddress LocalSubnet -Action Allow -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow 

New-NetFirewallRule -Name YAWC_Service -DisplayName “YAWC Service” -Description “YAWC Service” -Program "C:\Program Files (x86)\Yawcam\Yawcam_Service.exe" -Enabled True -Profile Any -Action Allow 


New-NetFirewallRule -Name YAWC_Service -DisplayName “YAWC Service” -Description “YAWC Service” -Program "C:\Program Files (x86)\Yawcam\Yawcam_Service.exe" -Protocol TCP -Profile Any -Action Allow -Enabled True


Remove-NetFirewallRule -Name YAWC_Service