
#+++ import modules

$modulePathBase = "$PSScriptRoot\..\..\..\Modules"

$pathArray = $( (Resolve-Path "$modulePathBase\Agt.Common\Public\").Path, `
            (Resolve-Path "$modulePathBase\Agt.Install\Public\").Path, `
            (Resolve-Path "$modulePathBase\Agt.Network\").Path)

foreach($path in $pathArray)
{
    foreach($item in (Get-ChildItem "$path\*.ps1"))
    {
        . "$($item.FullName)"
    }
}

Get-IsAdmin
Install-Far
Install-Powershell
Install-OpenSsh 
Set-OpenSsh

Write-Host -NoNewLine 'All task completed successfully...';
#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
