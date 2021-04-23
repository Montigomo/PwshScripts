# this script install powershell 7

# # import functions
# @(
#     "Invoke-RunAs",
#     "Get-IsAdmin",
#     "Get-Release",
#     "Install-MsiPackage",
#     "Set-EnvironmentVariablePath"
# ) |
# ForEach-Object {Import-Module -Name ("{0}\Learn\{1}.ps1" -f (Split-Path $PSScriptRoot -Parent), $_) -Verbose}

if(!(Get-IsAdmin))
{
    Write-Error "Run as administrator"
    exit
    $pswPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName;
    #$pp = $MyInvocation.MyCommand.Path
    if(((New-Object -TypeName System.Diagnostics.ProcessStartInfo -ArgumentList $pswPath).Verbs).Contains("runas"))
    {
        Start-Process -FilePath $pswPath -ArgumentList "-File $PSCommandPath" -Verb RunAs
    }
}

$pswhInstalled = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName.Contains("C:\Program Files\PowerShell\7\pwsh.exe");

#if(!$pswhInstalled)
#{

$pwshUri = Get-Release -Repouri "https://api.github.com/repos/powershell/powershell" -Pattern "PowerShell-\d.\d.\d-win-x64.msi"

# create temp file

$tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru

Invoke-WebRequest -OutFile $tmp $pwshUri

# ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL - This property controls the option for adding the Open PowerShell item to the context menu in Windows Explorer.
# ENABLE_PSREMOTING - This property controls the option for enabling PowerShell remoting during installation.
# REGISTER_MANIFEST - This property controls the option for registering the Windows Event Logging manifest.

Install-MsiPackage -FilePath $tmp.FullName -PackageParams "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1"

#}

#Pin-App  "PowerShell 7 (x64)"
#msiexec.exe /package PowerShell-7.0.0-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1


# Замена powershell по умолчании
# Установка модулей
