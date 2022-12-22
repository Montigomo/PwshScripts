


# setting for file and printers sharing

$filesAndPrintersSharing = @("File And Printer Sharing", "Общий доступ к файлам и принтерам")

try {
    
    foreach($item in $filesAndPrintersSharing){
        Set-NetFirewallRule -DisplayGroup $item -Enabled True -Profile Private
    }
}
catch {
    Write-Host $_
}

netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

netsh firewall set service type=fileandprint mode=enable profile=all


# setting Network sharing

netsh advfirewall firewall set rule group=”network discovery” new enable=yes

#Get-NetFirewallRule -DisplayGroup 'Network discovery' | Set-NetFirewallRule -Profile 'Private, Domain' -Enabled true

#Get-NetFirewallRule -DisplayGroup 'Обнаружение сети' | Set-NetFirewallRule -Profile 'Private, Domain' -Enabled true