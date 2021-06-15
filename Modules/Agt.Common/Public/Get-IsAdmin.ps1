
function Get-IsAdmin  
{  
    <#
    .SYNOPSIS
        Get Is powershell session runned in admin mode 
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
    # $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    # [bool](New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    # Determine if admin powershell process
    $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    [bool]$prp.IsInRole($adm)

}