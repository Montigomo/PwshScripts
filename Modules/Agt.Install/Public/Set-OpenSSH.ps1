
function DoConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$SrcFile,
        [Parameter()]
        [string]$DstFile,
        [Parameter()]
        [hashtable[]]$Patterns
    )

    function GetMatch {
        param(
            [object]$item
        )
        if ($item -is [string]) {
            $item
        }
        elseif ($item -is [hashtable]) {
            if ($item["Match"]) {
                $item["Match"] -f $item["Value"] 
            }
            else {
                $item["Value"]
            }
        }
    }
    function GetValue {
        param(
            [object]$item
        )
        if ($item -is [string]) {
            $item
        }
        elseif ($item -is [hashtable]) {
            $item["Value"]
        }
    }
    [Collections.Generic.List[String]]$Content = (Get-Content $SrcFile)

    foreach ($item in $Patterns) {
        $key = $item["Key"]
        $action = $item["Action"];
        $value = $item["Value"];
        $after = $item["After"];
        switch ($action) {
            "Uncomment" {
                $index = $Content.FindIndex([Predicate[String]] { param($s) $s -match (GetMatch $key) })
                if ($index -gt -1) {
                    $Content[$index] = $Content[$index] -replace '\#+(.*)', '$1'
                }
            }
            "Comment" {
                $indexFrom = 0;
                if ($after) {
                    $index = $Content.FindIndex([Predicate[String]] { param($s) $s -match (GetMatch $after) })
                    $indexFrom = if ($index -gt -1) { $index }else { 0 }
                }
                $index = $Content.FindIndex($indexFrom, [Predicate[String]] { param($s) $s -match (GetMatch $key) })
                if ($index -gt -1) {
                    $Content[$index] = "#$($Content[$index])"
                }
            }
            "SetValue" {
                $index = $Content.FindIndex([Predicate[String]] { param($s) $s -match (GetMatch $key) })
                if ($index -gt -1) {
                    $Content[$index] = "$(GetValue $key) $value"
                }
            }
            "Append" {
                $c = ($Content | Where-Object { $_ -eq $value }).Count
                if ($c -lt 1) {
                    if ($after) {
                        $index = $Content.FindIndex([Predicate[String]] { param($s) $s -match (GetMatch $after) })
                    }
                    if ($index -gt -1) {
                        $Content.Insert($index + 1, $value)
                    }
                    else {
                        $Content.Add($value);
                    }
                }               
            }
            "Distinct" {
                $c = ($Content | Where-Object { $_ -eq (GetValue $key) }).Count
                if ($c -le 1) {
                    continue;
                }
                do {
                    $Content.RemoveAt($Content.FindLastIndex([Predicate[String]] { param($s) $s -match (GetMatch $key) }));
                    $c = ($Content | Where-Object { $_ -eq (GetValue $key) }).Count
                }while ($c -gt 1)

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
        if ((get-service sshd).StartType -ne [System.ServiceProcess.ServiceStartMode]::Manual) {
            Get-Service -Name ssh-agent | Set-Service -StartupType 'Automatic'
        }
        Start-Service ssh-agent
    }

    $sshConfigFile = "$env:ProgramData/ssh/sshd_config"

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

    # prepare config file
    $patterns = @(
        @{
            "Key"    = @{"Value" = "PubkeyAuthentication"; "Match" = "\#?\s*{0}.*" }; 
            "Action" = "SetValue"; 
            "Value"  = "yes" 
        },
        @{
            "Key"    = @{"Value" = "StrictMode"; "Match" = "\#?\s*{0}.*" };
            "Action" = "SetValue"; 
            "Value"  = "no" 
        }
        @{
            "Key"    = @{"Value" = "PasswordAuthentication"; "Match" = "\#?\s*{0}.*" };
            "Action" = "SetValue"; 
            "Value"  = "no" 
        }
        @{
            "Key"    = @{"Value" = "Subsystem" }; 
            "Action" = "Append"; 
            "Value"  = "Subsystem powershell pwsh.exe -sshs -NoLogo -NoProfile";
            "After"  = "\#\s*override default of no subsystems"; 
        }
        @{
            "Key"    = @{"Value" = "Subsystem powershell pwsh.exe -sshs -NoLogo -NoProfile" }; 
            "Action" = "Distinct"; 
        }
        @{
            "Key"    = @{"Value" = "Match Group administrators" };
            "Action" = "Comment"; 
        }
        @{
            "Key"    = @{"Value" = "AuthorizedKeysFile" };
            "Action" = "Comment"; 
            "After"  = @{"Value" = "Match Group administrators"; "Match" = "\#?\s*{0}.*" }
        }
    )
    
    $SrcFile = $sshConfigFile
    $DstFile = $sshConfigFile

    DoConfig -SrcFile $SrcFile -DstFile $DstFile -Patterns $patterns

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