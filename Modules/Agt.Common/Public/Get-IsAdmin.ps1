
function Get-IsAdmin  
{  
    <#
    .SYNOPSIS
        Is powershell session runned in admin mode 
    .DESCRIPTION
    .PARAMETER Name
    .INPUTS
    .OUTPUTS
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