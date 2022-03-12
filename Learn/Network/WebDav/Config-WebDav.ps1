


$features = @(
    "IIS-WebServerRole","IIS-WebServer","IIS-CommonHttpFeatures",
    "IIS-HttpErrors","IIS-Security","IIS-RequestFiltering",
    "IIS-WebServerManagementTools","IIS-DigestAuthentication",
    "IIS-StaticContent","IIS-DefaultDocument","IIS-DirectoryBrowsing",
    "IIS-WebDAV","IIS-BasicAuthentication","IIS-ManagementConsole"
    );

foreach ($feature in $features)
{
    Enable-WindowsOptionalFeature -Online -FeatureName $feature
};

New-SelfSignedCertificate -DnsName odrive-self-signed -CertStoreLocation "cert:\LocalMachine\My";

#& "$env:windir\system32\inetsrv\InetMgr.exe";


### Check and install IISAdministration module


### Add/Edit firewall rule
#New-NetFirewallRule -Name TightVNC -DisplayName "IISWebDav 4433" -Description "IISWebDav 4433" -Program "C:\Program Files\TightVNC\tvnserver.exe" -Enabled True -Profile Any -Action Allow 
New-NetFirewallRule -Name TightVNC -DisplayName "IISWebDav 4433" -Description "IISWebDav 4433" -Direction Inbound -Enabled True -Profile Any -Action Allow -LocalPort 4433 -Protocol TCP
