

$Logfile = "$PSScriptRoot\cupdater.log"

function WriteLog {
    Param ([string]$LogString)
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
        Write-Host "Runned as admin"
        Write-Host "Installing far ..."
        Install-Far
        Write-Host "Installing pwsh ..."
        Install-Powershell
        Write-Host "Installing ssh ..."
        Install-OpenSsh 
        Write-Host "Config ssh ..."
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
