
function ReplaceString{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$SrcFile,
        [Parameter()]
        [string]$DstFile,
        [Parameter()]
        [string[]]$Patterns
    )

    $Content = Get-Content $SrcFile

    foreach ($itemj in $Patterns) {
        $tmp = $itemj.Split("|")        
        switch ($tmp[2]) {
            "replace" {
                $index = [System.Array]::IndexOf($Content, $tmp[0])
                if($index -lt 0)
                {
                    continue
                }
                $Content[$index] = $tmp[1]
            }
            "append" {
                $index = [System.Array]::IndexOf($Content, $tmp[1])
                # item already exists
                if($index -gt -1)
                {
                    continue
                }
                #
                $index = [System.Array]::IndexOf($Content, $tmp[0])
                if($index -lt 0)
                {
                    $Content = $Content + $tmp[1] 
                    continue
                }
                # find next section
                #$index2 = [System.Array]::IndexOf($Content, "# ", $index)
                $NewContent = $Content[0..$index]
                $NewContent += $tmp[1]
                $NewContent += $Content[($index + 1)..$Content.Length]
            }
        }
    }

    $Content |  Out-File $DstFile
}

function Set-OpenSsh {  
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
        if((get-service sshd).StartType -ne [System.ServiceProcess.ServiceStartMode]::Manual)
        {
            Get-Service -Name ssh-agent | Set-Service -StartupType 'Automatic'
        }
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

    # uncoment add replace config sile
    $patterns = @(
    "^\#PubkeyAuthentication yes|PubkeyAuthentication yes|replace",
    "^\#PasswordAuthentication no|PasswordAuthentication no|replace",
    "^\#PasswordAuthentication yes|PasswordAuthentication no|replace",
    "^PasswordAuthentication yes|PasswordAuthentication no|replace",
    "^\# override default of no subsystems|Subsystem	powershell pwsh.exe -sshs -NoLogo -NoProfile|append"
    )
    ReplaceString -SrcFile $sshConfigFile -DstFile $sshConfigFile -Patterns $patterns
    return
    #comment admin group match in ssh config file
    #Match Group administrators
    #       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
    $replaceSshConfigContent = $false
    if ($sshUseLocalAdminKeyFile) {
        $content = Get-Content $sshConfigFile;
        $inAdminMatchGroup = $false
        for ($cnt = 0; $cnt -lt $content.Count; $cnt++) {
            $line = $content[$cnt]
            
            # Match group
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

    # Restart service
    if (Get-Service  sshd -ErrorAction SilentlyContinue) {
        Get-Service -Name ssh-agent | Restart-Service 
    }
}