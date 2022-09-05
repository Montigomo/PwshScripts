
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

$sshPublicKeys = @(
    "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAiHq57Mo7efkA05q33JkdZ9g96VE4TjCn8lW0jZxn+n0TzkmlNZEi1E6fbfRSv3iK2XnNBFbOUBLinnMtzmDIAbez0FjKJOSyEk3ZvhD6QAvWh4UW77udzr1V9BROKDbe0ZpkHBHs4nc1LrjZ7+oAVnOHDpYa8FQh/jPf77js11YdNrrPbxi2Gg9SLpcDN6b8L88/eebWDaGNYzKw534eY7JT7FTUwcpAd0krfyh7h99pGJaWtzvwsot/ntQE0QiCmu2IXIYXz0iKBuI38PD9AAR3l7vsOzHIkWqcTRhNsfcrlvST8lZcrlOfwdK8peu1RGRegvWeL8tvunAd9rjBNQ== agitech"
)

Edit-OpenSSH -PublicKeys $sshPublicKeys -DisablePassword $true


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

