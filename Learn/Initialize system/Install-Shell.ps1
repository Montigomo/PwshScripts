
function Get-IsAdmin  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    [bool](New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

if(-not (Get-IsAdmin))
{
    Write-Output "Run as admin"
    exit
}

& "$PSScriptRoot\install-powershell.ps1"

& "$PSScriptRoot\config-powershell.ps1"

& "$PSScriptRoot\install-openssh.ps1"

& "$PSScriptRoot\config-openssh.ps1"

& "$PSScriptRoot\install-far.ps1"

# change folder C:\Users\agite\source\repos to D:\work