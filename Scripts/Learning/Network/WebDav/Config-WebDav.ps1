
function WriteLog {
    param (
        [string]$LogString
    )

    if (-not (Get-Variable -Name "LogFile" -ErrorAction SilentlyContinue) -or (Test-Path -Path $LogFile)) {
        $Logfile = "$PSScriptRoot\$($MyInvocation.MyCommand.Name).log"
    }

    Write-Host $LogString
    #$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    #$LogMessage = "$Stamp $LogString"
    #Add-content $LogFile -value $LogMessage
  }

function Enable-Features {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ParameterName
    )    

    $features = @(
        "IIS-WebServerRole",
        "IIS-WebServer",
        "IIS-CommonHttpFeatures",
        "IIS-HttpErrors",
        "IIS-Security",
        "IIS-RequestFiltering",
        "IIS-WebServerManagementTools",
        "IIS-DigestAuthentication",
        "IIS-StaticContent",
        "IIS-DefaultDocument",
        "IIS-DirectoryBrowsing",
        "IIS-WebDAV",
        "IIS-BasicAuthentication",
        "IIS-ManagementConsole"
        );

    foreach ($feature in $features)
    {
        WriteLog "Enabling feature $feature"
        Enable-WindowsOptionalFeature -Online -FeatureName $feature
    };
}

function CreateLocalUser{
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

# torn on features
Enable-Features

# install certificate
New-SelfSignedCertificate -DnsName odrive-self-signed -CertStoreLocation "cert:\LocalMachine\My";

#& "$env:windir\system32\inetsrv\InetMgr.exe";

# Add/Edit firewall rule
New-NetFirewallRule -Name IISWebDav -DisplayName "IISWebDav 4433" -Description "IISWebDav 4433" -Direction Inbound -Enabled True -Profile Any -Action Allow -LocalPort 4433 -Protocol TCP

# $users = @{"WebDavGazIsa"="webdavisa"}

# foreach($item in $users.Keys){
#     Create-LocalUser -UserName $item -Pwd $users[$item]
# }

