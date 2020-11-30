

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
function Set-EnvironmentVariablePath
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $Value,
        [Parameter(Mandatory=$false)]
        [ValidateSet('User', 'Process', 'Machine')]
        [string] $Scope = "User",
        [Parameter(Mandatory=$false)]
        [ValidateSet('Add', 'Remove')]
        [string] $Action = "Add"
    )
    
    switch($Action)
    {        
        "Add" {
            $path = [Environment]::GetEnvironmentVariable('Path', $Scope)
            if(!($path.Contains($Value)))
            {
                $newpath = $path + ";$Value"
                [Environment]::SetEnvironmentVariable("Path", $newpath, $Scope)
            }
        }
        "Remove" {
            $oev = [Environment]::GetEnvironmentVariable('Path', $Scope).Split(";")
            $oevNew = ($oev -notlike $Value -notlike "" -join ";")
            [Environment]::SetEnvironmentVariable("Path", $oevNew, $Scope) 
        }     
    }
}