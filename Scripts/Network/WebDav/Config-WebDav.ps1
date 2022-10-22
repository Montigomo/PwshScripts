

function Enable-Features {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ParameterName
    )    

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
}

function Create-LocalUser{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$true)]
        [string]$Pwd
    )
    $Description = "WebDav user $UserName"
    $SecurePassword = ConvertTo-SecureString $Pwd -AsPlainText -Force
    # Проверка наличия учетной записи
    if(!(Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue))
    {
        New-LocalUser -Name $UserName -Description $Description -Password $SecurePassword -AccountNeverExpires
    }else{
        Set-LocalUser -Name $UserName -Password $SecurePassword
    }
}

#Enable-Features
New-SelfSignedCertificate -DnsName odrive-self-signed -CertStoreLocation "cert:\LocalMachine\My";

#& "$env:windir\system32\inetsrv\InetMgr.exe";

### Add/Edit firewall rule
#New-NetFirewallRule -Name TightVNC -DisplayName "IISWebDav 4433" -Description "IISWebDav 4433" -Program "C:\Program Files\TightVNC\tvnserver.exe" -Enabled True -Profile Any -Action Allow 
New-NetFirewallRule -Name IISWebDav -DisplayName "IISWebDav 4433" -Description "IISWebDav 4433" -Direction Inbound -Enabled True -Profile Any -Action Allow -LocalPort 4433 -Protocol TCP

$users = @{"WebDavGazIsa"="webdavisa"}

foreach($item in $users.Keys){
    #Create-LocalUser -UserName $item -Pwd $users[$item]
}

