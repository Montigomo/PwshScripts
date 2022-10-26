


#$modulesPath = ([Environment]::GetEnvironmentVariable("PSModulePath",[System.EnvironmentVariableTarget]::Machine).Split(";"))[0];
$modulesPath = "C:\Program Files\WindowsPowerShell\Modules"

function Remove-Module
{
    <#
    
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]$Modules
    )

    foreach($item in $Modules)
    {
        if(Get-Module -Name $item)
        {
            $modulePath = (get-module $item).ModuleBase
            if($modulePath.StartsWith($PSScriptRoot))
            {
                continue
            }

            # Get-Childitem $modulePath -Recurse | ForEach-Object { 
            #     Remove-Item $_.FullName -Force
            # }
            Remove-Item -Path "$modulePath" -Force -Recurse
        }
    }
}

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
        [switch]$ImportModules
    )

$outputFileText = @'
{0}
function prompt {{
    $(if (Test-Path variable:/PSDebugContext) {{ '[DBG]: ' }}
        else {{ '' }}) + 'PS ' + $(Get-Location) +
        $(if ($NestedPromptLevel -ge 1) {{ '>>' }}) + '> '
}}
'@

    $profilePath = $profile.AllUsersAllHosts;

    $modules = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter *.psd1 `
               | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_).ToString() };

    Remove-Module -Modules $modules

    New-Item -ItemType Directory -Force -Path $modulesPath
    $items = Get-ChildItem -Path $PSScriptRoot -Directory
    Copy-Item $items -Destination $modulesPath -Recurse -Force

    $importString = @'
foreach($item in @({0}))
{{
    if(!(Get-Module $item))
    {{
        Import-Module -Name $item
    }}
}}
'@

    if($ImportModules)
    {
        $arraystr = ""
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
        $outputFileText = ($outputFileText -f ( $importString -f $arraystr))
    }
    else {
        $outputFileText = ($outputFileText -f "")
    }

    $outputFileText | Out-File -FilePath $profilePath

}

Install-Modules