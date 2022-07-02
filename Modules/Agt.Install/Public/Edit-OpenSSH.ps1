

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
        [Parameter(Mandatory = $true)]
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

    if ($sshPublicKey -is [System.Array]) {
        foreach ($sshPublicKey in $PublicKeys) {
            If (!(Select-String -Path $sshAuthKeys -pattern $sshPublicKey -SimpleMatch)) {
                Add-Content $sshAuthKeys $sshPublicKey
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