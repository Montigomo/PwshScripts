

$Logfile = "$PSScriptRoot\cupdater.log"
       
$sshPublicKeys = @(
    "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAiHq57Mo7efkA05q33JkdZ9g96VE4TjCn8lW0jZxn+n0TzkmlNZEi1E6fbfRSv3iK2XnNBFbOUBLinnMtzmDIAbez0FjKJOSyEk3ZvhD6QAvWh4UW77udzr1V9BROKDbe0ZpkHBHs4nc1LrjZ7+oAVnOHDpYa8FQh/jPf77js11YdNrrPbxi2Gg9SLpcDN6b8L88/eebWDaGNYzKw534eY7JT7FTUwcpAd0krfyh7h99pGJaWtzvwsot/ntQE0QiCmu2IXIYXz0iKBuI38PD9AAR3l7vsOzHIkWqcTRhNsfcrlvST8lZcrlOfwdK8peu1RGRegvWeL8tvunAd9rjBNQ== agitech"
)
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
        #Install-Far
        WriteLog "Installing pwsh ..."
        #Install-Powershell
        WriteLog "Installing ssh ..."
        Install-OpenSsh 
        WriteLog "Config ssh ..."
        
        Set-OpenSSH -PublicKeys $sshPublicKeys -DisablePassword $true

         # DNS Client
        # Function Discovery Provider Host
        # Function Discovery Resource Publication
        # HomeGroup Provider
        # HomeGroup Listener
        # Peer Networking Grouping
        # SSDP Discovery
        # UPnP Device Host
        
        $items = @("dnscache", "fdphost", "FDResPub", "p2psvc", "ssdpsrv", "upnphost")
        foreach($item in $items)
        {
            if(($service = Get-Service -Name $item -ErrorAction SilentlyContinue))
            {
                # ($service.StartType) -eq [System.ServiceProcess.ServiceStartMode]::Manual 
                if($service.StartType -ne [System.ServiceProcess.ServiceStartMode]::Automatic)
                {
                    $service | Set-Service -StartupType ([System.ServiceProcess.ServiceStartMode]::Automatic)
                }
                if($service.Status -ne "Running")
                {
                    $service | Start-Service
                }
            }
        }       

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
