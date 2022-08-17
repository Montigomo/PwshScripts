


function Edit-OpenSsh {  
    <#
    .SYNOPSIS
        
    .DESCRIPTION
    .PARAMETER Name
    .PARAMETER Extension
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Array]$PublicKeys,
        [Parameter(Mandatory = $false)]
        [System.Array]$PrivateKeys,
        [Parameter(Mandatory = $false)]
        [bool]$DisablePassword = $false
    )
    #configure and tuning ssh on windows 10

    # set ssh-agent service startup type
    if (Get-Service  ssh-agent -ErrorAction SilentlyContinue) {
        # if((get-service sshd).StartType -eq [System.ServiceProcess.ServiceStartMode]::Manual)
        Get-Service -Name ssh-agent | Set-Service -StartupType 'Automatic' 
        Start-Service ssh-agent
    }

    #Exit-PSHostProcess

    # private key  stored on client
    #ssh-add "$env:userprofile\.ssh\id_rsa"
    # public key distributed to servers
    # save public key to file  $env:userprofile\.ssh\authorized_keys.

    $sshConfigFile = "$env:ProgramData/ssh/sshd_config"

    $sshUseLocalAdminKeyFile = $true

    $sshAuthorizedKeys = @{
        local       = "$env:USERPROFILE\.ssh\authorized_keys";
        globalAdmin = "$env:ProgramData\ssh\administrators_authorized_keys"
    }

    $sshAuthKeys = $sshAuthorizedKeys["local"]

    if (!(Test-Path $sshAuthKeys)) {
        new-item -Path $sshAuthKeys  -itemtype File -Force
    }

    if ($sshPublicKeys -is [System.Array]) {
        foreach ($key in $PublicKeys) {
            If (!(Select-String -Path $sshAuthKeys -pattern $key -SimpleMatch)) {
                Add-Content $sshAuthKeys $key
            }
        }
    }
    
    foreach ($privateKey in $PrivateKeys) {
        if ( (Test-Path $privateKey) -and !((ssh-add -l).Contains($privateKey))) {
            ssh-add  $privateKey
        }
    }

    #comment admin group match in ssh config file
    #Match Group administrators
    #       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
    $replaceSshConfigContent = $false
    if ($sshUseLocalAdminKeyFile) {
        $content = Get-Content $sshConfigFile;
        $inAdminMatchGroup = $false
        for ($cnt = 0; $cnt -lt $content.Count; $cnt++) {
            $line = $content[$cnt]
            if ($inAdminMatchGroup) {
                if ($line -match "\AMatch ") {
                    $inAdminMatchGroup = $false
                }
                elseif ($line -match "\A\s*AuthorizedKeysFile") {
                    $content[$cnt] = ("#" + $line)
                    $replaceSshConfigContent = $true
                }
            }
            elseif ($line -match "\AMatch Group administrators\z") {
                $inAdminMatchGroup = $true
            }
            # PasswordAuthentication
            if ($DisablePassword) {
                if ($line -match "\A\#?PasswordAuthentication no|PasswordAuthentication yes") {
                    $content[$cnt] = "PasswordAuthentication no"
                    $replaceSshConfigContent = $true
                }
            }
            # PermitEmptyPasswords no
            
        }
        if ($replaceSshConfigContent) {
            Set-Content -Path $sshConfigFile -Value $content
        }
    }

    ### Config firewall

    if ((get-netfirewallrule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
        Remove-NetFirewallRule -Name "OpenSSH-Server-In-TCP"
    }
    if (-not (get-netfirewallrule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    }
}

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

