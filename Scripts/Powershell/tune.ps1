[CmdletBinding()]
param (
  [Parameter()]
  [string]$ParameterName
)

$thisFilePath = "$PSCommandPath"
$thisFileFolder = "$PSScriptRoot"

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

function AddRegFile {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string] $RegFilePath
  )
  $startprocessParams = @{
    FilePath     = "$Env:SystemRoot\REGEDIT.exe"
    ArgumentList = '/s', """$RegFilePath"""
    Verb         = 'RunAs'
    PassThru     = $true
    Wait         = $true
  }
  $proc = Start-Process @startprocessParams
    
  # if ($proc.ExitCode -eq 0) {
  #     'Success!'
  # }
  # else {
  #     "Fail! Exit code: $($Proc.ExitCode)"
  # }
}

function InstallApps {
  winget uninstall --name "Spotify Music"
  winget uninstall --name "Microsoft 365 (Office)"

  winget install -e --id RARLab.WinRAR
  winget install -e --id Notepad++.Notepad++
  winget install -e --id=Telegram.TelegramDesktop
  winget install -e --id Logitech.GHUB
  winget install -e --id DeepL.DeepL
  winget install -e --id OpenVPNTechnologies.OpenVPN
  winget install -e --id VideoLAN.VLC

  winget install Microsoft.DotNet.DesktopRuntime.7
  winget install Microsoft.DotNet.AspNetCore.7
  winget install Microsoft.DotNet.Runtime.7
}

function InstallMsvcrt {

  foreach ($item in (Get-ChildItem -Path "D:\_software\microsoft\msvcrt" -Recurse | Where-Object { $_ -is [System.IO.FileInfo] })) {
    if ([System.IO.Path]::GetExtension($item) -eq ".exe" -and [System.IO.Path]::GetFileNameWithoutExtension($item) -inotcontains "arm") {
      $startprocessParams = @{
        FilePath     = $item.FullName
        ArgumentList = '/q'
        Verb         = 'RunAs'
        PassThru     = $true
        Wait         = $true
      }
      Write-Output "Run $($item.FullName)"
      $proc = Start-Process @startprocessParams
    }
  }

}

function AddRegFiles {

  $regItemsFolder = (Join-Path $thisFileFolder "..\Registry") | Resolve-Path

  $items = @(
    "\Explorer_Expand to current folder_ON.reg",
    "\Context Menu\WIndows 11 classic context menu\win11_classic_context_menu.reg",
    "\Explorer_Activate Windows Photo Viewer on Windows 10.reg",
    "\Explorer_Show_extensions_for_known_file_types.reg",
    "\Explorer_Show_SuperHidden.reg",
    "\Explorer_Open_to_PC.reg"
  )
  
  foreach ($item in $items) {
    $filePath = "$regItemsFolder{0}" -f $item
    if (Test-Path -Path $filePath) {
      AddRegFile -RegFilePath $filePath
    }
    else {
      Write-Output "$filePath does not exist."
    }
  }

}

function PrepareHosts {

  #Add-Host -HostIp "163.172.167.207" -HostName "bt.t-ru.test.org"
  #Remove-Host  -HostIp "163.172.167.207" -HostName "bt.t-ru.org"
  #Add-Host -HostIp "163.172.167.207" -HostName "bt.t-ru.org"
  Add-Host -HostIp "0.0.0.0" -HostName "license.sublimehq.com"
  Add-Host -HostIp "83.243.40.67" -HostName "wiki.bash-hackers.org"

}

Write-Host "Finding modules ..." -ForegroundColor Green
. FindModules | Out-Null
Write-Output "Modules finded successfully."

#Install-WinRar

AddRegFiles

Write-Host "Install apps ..." -ForegroundColor Green
InstallApps

Write-Host "Install all Msvcrt ..." -ForegroundColor Green
InstallMsvcrt