
$Logfile = "$PSScriptRoot\install.log"
function WriteLog {
    param (
        [string]$LogString
    )

    if (-not (Get-Variable -Name "LogFile" -ErrorAction SilentlyContinue) -or (Test-Path -Path $LogFile)) {
        $Logfile = "$PSScriptRoot\$($MyInvocation.MyCommand.Name).log"
    }

    Write-Host $LogString
    #$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    #$LogMessage = "$Stamp $LogString"
    #Add-content $LogFile -value $LogMessage
}
  
function Get-IsAdmin {  
    $Principal = new-object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
    [bool]$Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function WriteLog {
    Param ([string]$LogString)
    Write-Host $LogString
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $LogFile -value $LogMessage
}

function FindModules {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ModulesFolder
    )
	
    $deep = 5;
	
    $folders = New-Object System.Collections.Generic.List[string]
	
    if (!$ModulesFolder) {
        $ModulesFolder = $PSScriptRoot
    }

    for ($i = 0; $i -le $deep; $i++) {
        $folders.Add("$ModulesFolder\$('..\'*$i)Modules");
    }
    foreach ($item in $folders) {
        if (Test-Path $item -PathType Container) {
            $modulePathBase = $item;
            break;
        }
    }

    $pathArray = $( (Resolve-Path "$modulePathBase\Agt.Common\Public\").Path, `
        (Resolve-Path "$modulePathBase\Agt.Install\Public\").Path, `
        (Resolve-Path "$modulePathBase\Agt.Network\").Path)

    foreach ($path in $pathArray) {
        foreach ($item in (Get-ChildItem "$path\*.ps1")) {
            . "$($item.FullName)"
        }
    }
}

if (Get-IsAdmin) {
    # try {

    WriteLog "Finding modules ..."
    . FindModules -ModulesFolder "D:\work\powershell\PwshScripts\Modules"
    WriteLog "Modules finded successfully."6


    Set-StartUp -Name "VirtalHere" -Path "D:\tools\network\VirtualHere\vhui64.exe"
    #Set-StartUp -Name "OpenVPN" -Path "C:\Program Files\OpenVPN\bin\openvpn-gui.exe" -Argument '--connect "sean_agitech.ovpn"'
    Set-StartUp -Name "SimpleDLNA" -Path "C:\Program Files (x86)\Nils Maier\SimpleDLNA\SimpleDLNA.exe"

    Start-Sleep -Seconds 7  
    # }
    # catch {
    #     WriteLog "GetFiles Error: $_"
    #     exit
    # }
}
else {
    Start-Process pwsh  -Verb "RunAs" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$PSCommandPath"""
}