
# [CmdletBinding()]
param
(
    #[Parameter(Mandatory)]
    # [string]$DefinitionName = "AdobeUpdaterX.xml",
    # [ValidateNotNullOrEmpty()]
    # [ValidateSet('xmrig','xmr-stak','dash')]
    # [string]$Method = 'xmrig',
    # [ValidateSet('system', 'author')]
    # [string]$Principal = 'author'
)


# create firewall rule
if((get-netfirewallrule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue))
{
    Remove-NetFirewallRule -Name "OpenSSH-Server-In-TCP"
}
if(-not (get-netfirewallrule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue))
{
    New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}