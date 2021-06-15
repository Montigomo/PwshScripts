
function Set-EnvironmentVariable
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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string] $Value,
        [Parameter(Mandatory=$false)]
        [ValidateSet('Path', 'PSModulePath')]
        $VariableName = "Path",
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
            $items = [Environment]::GetEnvironmentVariable($VariableName, $Scope)
            if(!($items.Contains($Value)))
            {
                $NewItem = $items + ";$Value"
                [Environment]::SetEnvironmentVariable($VariableName, $NewItem, $Scope)
            }
        }
        "Remove" {
            $oev = [Environment]::GetEnvironmentVariable($VariableName, $Scope).Split(";")
            $oevNew = ($oev -notlike $Value -notlike "" -join ";")
            [Environment]::SetEnvironmentVariable($VariableName, $oevNew, $Scope) 
        }     
    }
}