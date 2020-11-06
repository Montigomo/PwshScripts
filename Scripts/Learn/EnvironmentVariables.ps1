
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




$var1 = "D:\tools\far\"
$var2 = "C:\Program Files\Far Manager\Far.exe"
$var3 = "C:\Program Files\Far Manager"

# Set-EnvironmentVariablePath -Value $var1 -Scope "User" -Action "Remove"

Set-EnvironmentVariablePath -Value $var3 -Scope "User" -Action "Remove"

# Set-EnvironmentVariablePath -Value $var1 -Scope "Machine"  Action "Remove"


#Set-EnvironmentVariablePath -Value $var3 -Scope "User" -Action "Add"