
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
    # [CmdletBinding()]
    # param(
    #     [string]$Folder
    # )

$outSrting = @'
$modules = @(
    {0}
)

foreach($item in $modules)
{{
    if(!(Get-Module $item))
    {{
        Import-Module -Name $item
    }}
}}
function prompt {{
    $(if (Test-Path variable:/PSDebugContext) {{ '[DBG]: ' }}
        else {{ '' }}) + 'PS ' + $(Get-Location) +
        $(if ($NestedPromptLevel -ge 1) {{ '>>' }}) + '> '
}}
'@

    #C:\Program Files\WindowsPowerShell\Modules
    $modulesPath = ([Environment]::GetEnvironmentVariable("PSModulePath",[System.EnvironmentVariableTarget]::Machine).Split(";"))[0];
    $profilePath = $profile.AllUsersAllHosts;

    $ScriptPath = $MyInvocation.MyCommand.Path
    $items = Get-ChildItem -Path $PSScriptRoot -Recurse | Where-Object {$_.FullName -ne $ScriptPath}

    $modules = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter *.psd1 | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_).ToString() };

    foreach($item in $modules)
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

    $outputFileText = ( $outSrting -f $arraystr) 
    $outputFileText | Out-File -FilePath $profilePath

}

Install-Modules