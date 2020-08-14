
function Get-IsAdmin  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    [bool](New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

Write-Output $PSVersionTable.PSVersion

Get-IsAdmin

start-sleep 5



exit