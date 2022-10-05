

$Logfile = "$PSScriptRoot\cupdater.log"

function WriteLog {
    Param ([string]$LogString)
    Write-Host $LogString
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $LogFile -value $LogMessage
}

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



if(Get-IsAdmin)
{
    try{
        WriteLog "Runned as admin"
        WriteLog "Installing far ..."
        Install-Far
        WriteLog "Installing pwsh ..."
        Install-Powershell
        WriteLog "Installing ssh ..."
        Install-OpenSsh 
        WriteLog "Config ssh ..."
        Set-OpenSsh
    }catch{
        WriteLog "GetFiles Error: $_"
        exit
    }
}
else {
    Write-Host "Script worked correctly only in admin mode."
    exit
}

Write-Host -NoNewLine 'All task completed successfully...';
#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
