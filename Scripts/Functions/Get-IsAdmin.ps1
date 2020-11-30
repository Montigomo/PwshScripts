
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
http://www.xxx.com
#>
function Get-IsAdmin  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    [bool](New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}