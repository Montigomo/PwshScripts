# to do
# Get-SymlinkTarget C:\Users\agite\Music
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
function msgBox($x){
	[System.Windows.Forms.MessageBox]::Show($x, 'Done!:PowerShell', 
		[Windows.Forms.MessageBoxButtons]::OK, 
		[Windows.Forms.MessageBoxIcon]::Information, [Windows.Forms.MessageBoxDefaultButton]::Button1,
		[Windows.Forms.MessageBoxOptions]::ServiceNotification)
}

function Install-AgtModules
{
	[CmdletBinding()]
	Param
	()
	Process
	{
		$mpath = $PSScriptRoot + '\Modules'
		$p = [Environment]::GetEnvironmentVariable("PSModulePath",[System.EnvironmentVariableTarget]::User)
		if(!(Test-Path $mpath)) { return; }
		if((!$p) -or (!($p.Split(';')).Contains($mpath)))
		{
			#Add the new path to the $p variable. Begin with a semi-colon separator.
			if($p)
			{ $p += ";$mpath"; }
			else
			{ $p += "$mpath"; }
			#  Add the paths in $p to the PSModulePath value.
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
		New-Item $profile.CurrentUserAllHosts -ItemType file -Force
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

function Install-Keys
{
    
}


Install-AgtModules
Load-AgtModule

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

#######   Modules Installed   #######

$sa = ((Get-KnownFolderPath -KnownFolder Profile) + '\')
$ss = "D:\___users\_ali\";

if(!(Test-Path $ss)){ New-Item -ItemType Directory -Force -Path $ss };
if(!(Test-Path $ss)){ return };

$userFolders = @{
	'Documents' = @(($sa + 'Documents'), ($ss + 'Documents'));
	'Videos'    = @(($sa + 'Videos'), ($ss + 'Videos'));
	'Pictures'  = @(($sa + 'Pictures'), ($ss + 'Pictures'));
	'Music'     = @(($sa + 'Music'), ($ss + 'Music'));
    'Desktop'     = @(($sa + 'Desktop'), ($ss + 'Desktop'));
	'Favorites' = @(($sa + 'Favorites'), ($ss + 'Favorites'))}

function Create-SymLinks
{
	Param()
	foreach($value in $userFolders.GetEnumerator())
	{
		$curPathC = $value.Value[0];
		$curPathD = $value.Value[1];
		if((Test-Path -Path $curPathC))
		{
			$symTargetPath = Get-SymlinkTarget $curPathC;
			if($symTargetPath -ne $curPathD)
			{
                TAKEOWN /F $curPathC /R /A /D Y
				if(Test-Symlink $curPathC){
                    Remove-Symlink $curPathC;
                }else{
                    Remove-Item $curPathC -Force -Recurse;
                }
				New-Symlink -SrcPath $curPathD -DstPath $curPathC;
			}
		}else
        {
            New-Symlink -SrcPath $curPathD -DstPath $curPathC;
        }
	}
}

Create-SymLinks
Set-UACLevel -Level 0
Set-PowAsDefault -On
Set-OSCPowerButtonAction -Action ShutDown

foreach($value in $userFolders.GetEnumerator())
{
	$curPath = $value.Value[1];
	if(!(Test-Path $curPath)){ New-Item -ItemType Directory -Force -Path $curPath };
	if(!(Test-Path $curPath)){ continue };
	Write-Output ('Setting Known folder {0} - {1}' -f $curPath, (Set-KnownFolderPath -KnownFolder $value.Name -Path $curPath));
}

$regfolder = (Get-KnownFolderPath -KnownFolder OneDriveFolder) + '\Powershell\Scripts\registry\';

$regitems = @(
		($regfolder + 'Activate Windows Photo Viewer on Windows 10.reg'),
		($regfolder + 'Change-KeyboardToggle.reg')
		($regfolder + '260 Character Path Limit Remove.reg'),
		($regfolder + 'Ps_Open_Run')
		);

# REG  don't work with onedrive files ....
foreach($value in $regitems){ regedit /s $value }

powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

Set-PowerMode -PowerMode 'Ultimate performance'