


function Install-MsiPackage
{
    $DataStamp = get-date -Format yyyyMMddTHHmmss
    $logFile = '{0}-{1}.log' -f $file.fullname,$DataStamp
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f $file.fullname)
        "/qn"
        "/norestart"
        "/L*v"
        $logFile
    )
    Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
}

function Test-Administrator  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    [bool](New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

# $PSVersionTable
# $MyInvocation | format-list *
# Get-Host
# $host


#$tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } –PassThru


#msiexec.exe /package PowerShell-7.0.0-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1


# Set Remove Path variable
function Operate-EnvPath
{
    param(
        [string]
        $value
    )
    $pathArray = [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) -split ";" | Where-Object {$_} | Select-Object {$_.ToLower()}

}


# crete shortcuts
function Set-ShortCut
{
    param ( 
        [Parameter(Mandatory = $true,Position = 0,
        HelpMessage="Shortcut target path.")] 
        [string]$SourcePath, 
        [Parameter(Mandatory = $true,Position = 1,
        HelpMessage="Shortcut location.")] 
        [string]$DestinationPath 
    )

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($DestinationPath)
    $Shortcut.TargetPath = $SourcePath
    $Shortcut.Save()
}


$lnkDstPath = Join-Path (Get-KnownfolderPath -KnownFolder Desktop) "OneDrive.lnk"
$lnkSrcPath = (Get-KnownfolderPath -KnownFolder OneDriveFolder)

Set-ShortCut $lnkSrcPath $lnkDstPath


# UAC 
#
#

(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System).EnableLUA

Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0