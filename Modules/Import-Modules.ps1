
$modulePathBase = "$PSScriptRoot"

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