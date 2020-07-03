
#configure and tuning ssh on windows 10

# set ssh-agent service startup type
if(Get-Service  ssh-agent -ErrorAction SilentlyContinue)
{
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
    local = "$env:USERPROFILE\.ssh\authorized_keys";
    globalAdmin = "$env:ProgramData\ssh\administrators_authorized_keys"
}

$sshAuthKeys = $sshAuthorizedKeys["local"]

if(!(Test-Path $sshAuthKeys))
{
    new-item -Path $sshAuthKeys  -itemtype File -Force
}

#$sshPublicKey = Get-Content -Path "D:\tools\network\keys\agitech\G75V\primary\primary.pub" -Raw
$sshPublicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC32E/9EFRJ6fKI8uFMYLTPTSWDkobhlX4t5TBk1nzAho1nZwpZ4a1dy4kc9+PXzBxWF7OLIzYpXTV0vH5UjIrD6gIyutC0Ju8XAO3s+CKk+pm5m5Ku4om8rm7dps2MugiA1M3b7MCPsG5SwfeJkm78PTC6KhzzenguE1FCbYEcChEwfMxQ8m3B6EQcZWJG9X8H9Xz05mvSoxjjkE/xkbbpyOfWXgApjf9iKmdTovWkMQXepUzIr22OoMkPMgtu4SDv1hNu6gty6NoePK/6v+RZbsTrBfgofy5oLXGTEBmr5FU773l8m8x5tyxR6SKXpQT3udSFT17y58m5e50FSmhL agite@AgiG75V"

#comment admin group match in ssh config file
#Match Group administrators
#       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
$replaceSshConfigContent = $false
if($sshUseLocalAdminKeyFile)
{
    $sshConfigFile = "D:\temp\2\sshd_config"
    $content = Get-Content $sshConfigFile;
    $inAdminMatchGroup = $false
    for($cnt = 0; $cnt -lt $content.Count; $cnt++)
    {
        $line = $content[$cnt]
        if($inAdminMatchGroup)
        {
            if($line -match "\AMatch ")
            {
                $inAdminMatchGroup = $false
            }
            elseif($line -match "\A\s*AuthorizedKeysFile")
            {
                $content[$cnt] = ("#" + $line)
                $replaceSshConfigContent = $true
            }
        }
        elseif($line -match "\AMatch Group administrators\z")
        {
            $inAdminMatchGroup = $true
        }
    }
    if($replaceSshConfigContent)
    {
        Set-Content -Path $sshConfigFile -Value $content
    }
}


If (!(Select-String -Path $sshAuthKeys -pattern $sshPublicKey -SimpleMatch))
{
    Add-Content $sshAuthKeys $sshPublicKey
}
