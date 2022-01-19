
function Set-EnvironmentVariable
{
    <#
    .SYNOPSIS
        Get Is powershell session runned in admin mode 
    .DESCRIPTION
    .PARAMETER Value
        Environment variable value
    .PARAMETER Name
        Environment variable name [ValidateSet('Path', 'PSModulePath')]
    .PARAMETER Scope
        Scope  [ValidateSet('User', 'Process', 'Machine')]
    .PARAMETER Action
        Action [ValidateSet('Add', 'Remove')]
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string] $Value,
        [Parameter(Mandatory=$false)]
        [ValidateSet('Path', 'PSModulePath')]
        $Name = "Path",
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
            $items = [Environment]::GetEnvironmentVariable($Name, $Scope)
            if(!($items.Contains($Value)))
            {
                $NewItem = $items + ";$Value"
                [Environment]::SetEnvironmentVariable($Name, $NewItem, $Scope)
            }
        }
        "Remove" {
            $items = [Environment]::GetEnvironmentVariable($Name, $Scope).Split(";")
            $oevNew = ($items -notlike $Value -notlike "" -join ";")
            [Environment]::SetEnvironmentVariable($Name, $oevNew, $Scope) 
        }     
    }
}

#Set-EnvironmentVariable -Name 'Path' -Scope 'Machine' -Value "c:\Program Files\OpenSSH\"