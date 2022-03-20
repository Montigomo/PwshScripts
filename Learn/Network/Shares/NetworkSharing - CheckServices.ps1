


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