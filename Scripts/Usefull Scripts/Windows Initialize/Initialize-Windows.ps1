
enum Computer{
    Common = 0
    Nidaleb = 1
    AgiDesktop = 2
    AgiLaptop = 3
} 

[Computer]$computer = [Computer]::AgiLaptop

$mandatoryModules = @("Agt.Common", "Agt.Install", "Agt.Network")
$result = $true;

foreach($item in $mandatoryModules)
{
    if(!(get-module $item))
    {
        $result = $false;
        break;
    }
}
if(!($result))
{
    exit;
}

#Install-Ssh

#
#

$sshPublicKeys = @{
    [Computer]::AgiLaptop = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC32E/9EFRJ6fKI8uFMYLTPTSWDkobhlX4t5TBk1nzAho1nZwpZ4a1dy4kc9+PXzBxWF7OLIzYpXTV0vH5UjIrD6gIyutC0Ju8XAO3s+CKk+pm5m5Ku4om8rm7dps2MugiA1M3b7MCPsG5SwfeJkm78PTC6KhzzenguE1FCbYEcChEwfMxQ8m3B6EQcZWJG9X8H9Xz05mvSoxjjkE/xkbbpyOfWXgApjf9iKmdTovWkMQXepUzIr22OoMkPMgtu4SDv1hNu6gty6NoePK/6v+RZbsTrBfgofy5oLXGTEBmr5FU773l8m8x5tyxR6SKXpQT3udSFT17y58m5e50FSmhL agite@AgiG75V";
    [Computer]::AgiDesktop = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAiHq57Mo7efkA05q33JkdZ9g96VE4TjCn8lW0jZxn+n0TzkmlNZEi1E6fbfRSv3iK2XnNBFbOUBLinnMtzmDIAbez0FjKJOSyEk3ZvhD6QAvWh4UW77udzr1V9BROKDbe0ZpkHBHs4nc1LrjZ7+oAVnOHDpYa8FQh/jPf77js11YdNrrPbxi2Gg9SLpcDN6b8L88/eebWDaGNYzKw534eY7JT7FTUwcpAd0krfyh7h99pGJaWtzvwsot/ntQE0QiCmu2IXIYXz0iKBuI38PD9AAR3l7vsOzHIkWqcTRhNsfcrlvST8lZcrlOfwdK8peu1RGRegvWeL8tvunAd9rjBNQ== agite@AgiDesktop"
}

$sshPrivateKeys = @{
    [Computer]::AgiDesktop = "$PSScriptRoot\keys\Desktop.primary.rsa.notcrypted.openssh";
    [Computer]::AgiLaptop = "$PSScriptRoot\keys\g75v.primary.rsa.notcrypted.OpenSSH"
}

$sshPublicKey = $sshPublicKeys[[Computer]$computer];
$sshPrivateKey = $sshPrivateKeys[[Computer]$computer];


Edit-OpenSSH -PublicKeys $sshPublicKeys.Values -PrivateKeys $sshPrivateKey -DisablePassword $true


# If none of those work, make sure all networking services are running. The following services should all be set to Automatic and be currently running:

# DNS Client
# Function Discovery Provider Host
# Function Discovery Resource Publication
# HomeGroup Provider
# HomeGroup Listener
# Peer Networking Grouping
# SSDP Discovery
# UPnP Device Host

$items = @("dnscache", "fdphost", "FDResPub", "p2psvc", "ssdpsrv", "upnphost")
foreach($item in $items)
{
    if(($service = Get-Service -Name $item -ErrorAction SilentlyContinue))
    {
        # ($service.StartType) -eq [System.ServiceProcess.ServiceStartMode]::Manual 
        if($service.StartType -ne [System.ServiceProcess.ServiceStartMode]::Automatic)
        {
            $service | Set-Service -StartupType ([System.ServiceProcess.ServiceStartMode]::Automatic)
        }
        if($service.Status -ne "Running")
        {
            $service | Start-Service
        }
    }
}