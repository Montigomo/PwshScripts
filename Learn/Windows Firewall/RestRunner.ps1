


Import-Module NetSecurity


# rest web api

New-NetFirewallRule -Name "RestWebRunner" -DisplayName “RestWebRunner” -Description “RestWebRunner” -Protocol TCP -Profile Any -Action Allow -Enabled True -LocalPort 8080