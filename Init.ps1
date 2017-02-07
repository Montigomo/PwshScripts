
# to do

function Install-AgtModules
{
<#  
.SYNOPSIS  
.DESCRIPTION
    Install user modules
.NOTES  
    File Name   : Install-AgtModules.ps1  
    Author      : Query Maridy
    Prerequisite: PowerShell V2 on Vista and later versions.
    Copyright 2014 - Query Maridy    
.LINK  
    Script posted on:  http://www.qmaridy.com  
.EXAMPLE 
    PS Install-AgtModules
    Call Powershell for .PS1 files.
#>
    [CmdletBinding()]
    Param
    ()
    Process
    {
        $mpath = $PSScriptRoot + '\Modules'
        #(get-itemproperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name PSModulePath).PSModulePath.Split(';')
        #(get-itemproperty 'HKCU:\Environment' -Name PSModulePath).PSModulePath.Split(';')
        #Save the current value in the $p variable.
        $p = [Environment]::GetEnvironmentVariable("PSModulePath",[System.EnvironmentVariableTarget]::User)
        if(!(Test-Path $mpath)) { return; }

        if((!$p) -or (!($p.Split(';')).Contains($mpath)))
        {
            #Add the new path to the $p variable. Begin with a semi-colon separator.
            if($p)
            {
                $p += ";$mpath"
            }
            else
            {
                $p += "$mpath"
            }
            
            #Add the paths in $p to the PSModulePath value.
            [Environment]::SetEnvironmentVariable("PSModulePath",$p,[System.EnvironmentVariableTarget]::User)
        }          

    }
}


function Load-AgtModule
{
    Param()
    #Get-Module -ListAvailable  -Name 'Agt*' | ForEach-Object { if(-not(Get-Module -Name $_.Name)) { Import-Module $_.Name} }
    
    $srcProfilePath = $PSScriptRoot + "\profiles\profile.ps1"
    
    $st = "###Agitech edition###" #'Get-Module -ListAvailable  -Name "Agt*" | ForEach-Object { if(-not(Get-Module -Name $_.Name)) { Import-Module $_.Name} }'

    if(!(Test-Path $srcProfilePath)) { return; }

    if(!(Test-Path $profile.CurrentUserAllHosts))
    {
        new-item $profile.CurrentUserAllHosts -ItemType file -Force
    }

    $pc = Get-Content $profile.CurrentUserAllHosts
    
    if(!$pc)
    {
        Copy-Item $srcProfilePath $profile.CurrentUserAllHosts -Force
        $pc = Get-Content $profile.CurrentUserAllHosts
    }

    if(!($pc.Contains($st)))
    {
        $pc += [Environment]::NewLine + $st
        $pc | Out-File $profile.CurrentUserAllHosts -Force
    }
}

################################
#      Install section
################################


Install-AgtModules
Load-AgtModule


################################
#      Init section
################################

$ss = "D:\___users\_ali\";
if(!(Test-Path $ss)){ New-Item -ItemType Directory -Force -Path $ss };
if(!(Test-Path $ss)){ return };

$userFolders = @{'Documents' = $ss + 'Documents';
                 'Videos' = $ss  + 'Videos';
                 'Pictures' = $ss + 'Pictures';
                 'Music' = $ss + 'music';
                 'Favorites' = $ss + 'Favorites'}

#checks for installed modules
$checkModules = $false;
try
{
    $checkModules = IsModulesExists;
}
catch [System.Management.Automation.CommandNotFoundException]
{
    $te = $_;
}
if(!($checkModules))
{
    Write-Output "Install required modules and then rerun."
    Exit
}

#
Set-UACLevel -Level 0
#
Set-PowAsDefault -On
#
Set-PowerMode -PowerMode 'High performance'
#
Set-OSCPowerButtonAction -Action ShutDown
#
foreach($value in $userFolders.GetEnumerator())
{
    if(!(Test-Path $value.Value)){ New-Item -ItemType Directory -Force -Path $value.Value };
    if(!(Test-Path $value.Value)){ continue };
    #$skfr = Set-KnownFolderPath -KnownFolder $value.Name -Path $value.Value
    $rs = if((Set-KnownFolderPath -KnownFolder $value.Name -Path $value.Value) -eq 0) {'success'} else {'failure'};
    Write-Output ('Setting Known folder {0} - {1}' -f $value.Name, $rs);
}