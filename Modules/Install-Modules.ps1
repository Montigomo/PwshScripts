
function Install-Modules
{  
    <#
    .SYNOPSIS
        Try install underlying modules to system
    .DESCRIPTION
    .PARAMETER Folder
        folder where modules be installed
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    param(
        [string]$Folder
    )

    $outSrting = '
    $modules = @(
        {1}
    )

    foreach($item in $modules)
    {{
        if(!(Get-Module $item))
        {{
            Import-Module -Name $item
        }}
    }}'

    #C:\Program Files\WindowsPowerShell\Modules
    $modulesPath = ([Environment]::GetEnvironmentVariable("PSModulePath",[System.EnvironmentVariableTarget]::Machine).Split(";"))[0];
    $profilePath = $profile.AllUsersAllHosts;
6
    $ScriptPath = $MyInvocation.MyCommand.Path
    $items = Get-ChildItem -Path $PSScriptRoot -Recurse | Where-Object {$_.FullName -ne $ScriptPath}

    $modules = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter *.psd1 | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_).ToString() };

    New-Item -ItemType Directory -Force -Path $modulesPath

    $arraystr = ""

    Copy-Item $items -Destination $modulesPath -Recurse -Force

    foreach($item in $modules)
    {
        if($arraystr.Length -eq 0)
        {
            $arraystr += ('"{0}"' -f $item)
        }
        else
        {
            $arraystr += (', "{0}"' -f $item)
        }
    }

    $outputFileText = ( $outSrting -f $destinatinFunctionFolder, $arraystr) 
    $outputFileText | Out-File -FilePath $profilePath

}