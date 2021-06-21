
function Edit-Natwork
{  
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


    #enable file printer sharing 

    Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Disable-NetFirewallRule

    Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Enable-NetFirewallRule
}