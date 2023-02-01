
Import-Module NetSecurity

#turn on off windows firewall
#Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
# Ultra Vnc rules
#New-NetFirewallRule -Name "Uvnc_Service" -DisplayName “Unvc Service” -Description “Uvnc Service” -Program "C:\Program Files\uvnc bvba\UltraVNC\winvnc.exe" -Protocol TCP -Profile Any -Action Allow -Enabled True
# tightvnc
#New-NetFirewallRule -Name TightVNC -DisplayName "TightVNC Service" -Description "TightVNC Service" -Program "C:\Program Files\TightVNC\tvnserver.exe" -Enabled True -Profile Any -Action Allow 

function RestWeb{
	Import-Module NetSecurity
	# rest web api
	New-NetFirewallRule -Name "RestWebRunner" -DisplayName “RestWebRunner” -Description “RestWebRunner” -Protocol TCP -Profile Any -Action Allow -Enabled True -LocalPort 8080
}

function FilePrinterShares{
	Set-NetFirewallRule -DisplayGroup “File And Printer Sharing” -Enabled True -Profile Private
}

function YawcRules{

	# New-NetFirewallRule -Name YAWC_Service -DisplayName “YAWC Service” -Description “YAWC Service” `
	#     -Program "C:\Program Files (x86)\Yawcam\Yawcam_Service.exe" -RemoteAddress LocalSubnet `
	#     -Action Allow -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow 

	New-NetFirewallRule -Name YAWC_Service -DisplayName "YAWC Service" -Description "YAWC Service" `
		-Program "C:\Program Files (x86)\Yawcam\Yawcam_Service.exe" -Profile Any -Action Allow -Enabled True

	# New-NetFirewallRule -Name YAWC_Service -DisplayName "YAWC Service" -Description "YAWC Service" `
	#     -Program "C:\Program Files (x86)\Yawcam\Yawcam_Service.exe" -Protocol TCP -Profile Any -Action Allow -Enabled True

	# Remove-NetFirewallRule -Name YAWC_Service
}

function SqlServer{
	New-NetFirewallRule -DisplayName "SQLServer default instance" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow
	New-NetFirewallRule -DisplayName "SQLServer Browser service" -Direction Inbound -LocalPort 1434 -Protocol UDP -Action Allow	
}

function GitServer{
	[CmdletBinding()]
	param ([Parameter()][switch]$Remove)
	New-NetFirewallRule -Name "BonoboGetServer" -DisplayName "Bonobo Git Server" -Description "Git Server" `
	-Protocol TCP -Profile Any -Action Allow -Enabled True -LocalPort 8888
}

GitServer