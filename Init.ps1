
# to do

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
function msgBox($x){
		[System.Windows.Forms.MessageBox]::Show($x, 'Done!:PowerShell', 
	[Windows.Forms.MessageBoxButtons]::OK, 
	[Windows.Forms.MessageBoxIcon]::Information, [Windows.Forms.MessageBoxDefaultButton]::Button1,
	[Windows.Forms.MessageBoxOptions]::ServiceNotification
		)
}

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
		Copyright 2014 - Agitech    
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

		#msgBox($PSScriptRoot);

		#$oReturn=[System.Windows.Forms.Messagebox]::Show($PSScriptRoot);

		#exit;
		
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

#######   userFoldes   #######
$sa = ((Get-KnownFolderPath -KnownFolder Profile) + '\')
$ss = "D:\___users\_ali\";

if(!(Test-Path $ss)){ New-Item -ItemType Directory -Force -Path $ss };
if(!(Test-Path $ss)){ return };

$userFolders = @{
	'Documents' = @(($sa + 'Documents'), ($ss + 'Documents'));
	'Videos'    = @(($sa + 'Videos'), ($ss + 'Videos'));
	'Pictures'  = @(($sa + 'Pictures'), ($ss + 'Pictures'));
	'Music'     = @(($sa + 'Music'), ($ss + 'Music'));
	'Favorites' = @(($sa + 'Favorites'), ($ss + 'Favorites'))}

$t = $userFolders['Music'][0];

function Create-SymLinks
{
    Param()
    foreach($value in $userFolders.GetEnumerator())
    {
        $curPathA = $value.Value[0];
        $curPathB = $value.Value[1];
        if((Test-Path -Path $curPathA))
        {
            if(Test-Symlink $curPathA)
            {
                Remove-Symlink $curPathA
            }
            else
            {
                Remove-Item $curPathA -Force -Recurse
            }
        }
        New-Symlink -SrcPath $curPathB -DstPath $curPathA
    }
}
#
# Guid FOLDERID_SkyDrive = new Guid("A52BBA46-E9E1-435f-B3D9-28DAA648C0F6");
# location = GetKnownFolderPath(FOLDERID_SkyDrive);
Get-KnownFolderPath -Knownfolder 'OneDriveFolder'


#######   Install section   #######


Install-AgtModules
Load-AgtModule


#######    Init section      #######


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

Create-SymLinks
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
    $curPath = $value.Value[1];
    if(!(Test-Path $curPath)){ New-Item -ItemType Directory -Force -Path $curPath };
	if(!(Test-Path $curPath)){ continue };
	#$skfr = Set-KnownFolderPath -KnownFolder $value.Name -Path $value.Value
	#$rs = if((Set-KnownFolderPath -KnownFolder $value.Name -Path $value.Value) -eq 0) {'success'} else {'failure'};
	Write-Output ('Setting Known folder {0} - {1}' -f $curPath, (Set-KnownFolderPath -KnownFolder $value.Name -Path $curPath));
}

powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61