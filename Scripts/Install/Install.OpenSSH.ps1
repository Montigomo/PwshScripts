
# import functions
@(
    "Invoke-RunAs",
    "Get-IsAdmin",
    "Get-Release",
    "Install-MsiPackage",
    "Set-EnvironmentVariablePath"
) |
ForEach-Object {Import-Module -Name ("{0}\Learn\{1}.ps1" -f (Split-Path $PSScriptRoot -Parent), $_) -Verbose}

### Download OpenSSH archive from github and try to install it

$osuri = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.1.0.0p1-Beta/OpenSSH-Win64.zip"

$destPath = "c:\Program Files\OpenSSH\"

$installScriptPath = Join-Path $destPath "install-sshd.ps1"

function Test-Administrator  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    [bool](New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

# create target directory
[System.IO.Directory]::CreateDirectory($destPath)
#New-Item -ItemType Directory -Path $destPath -Force

# create temp with zip extension (or Expand will complain)
$tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } –PassThru
#download
Invoke-WebRequest -OutFile $tmp $osuri

#exract to destination folder 
#$tmp | Expand-Archive -DestinationPath $destPath -Force

Add-Type -Assembly System.IO.Compression.FileSystem

#extract list entries for dir 
$zip = [IO.Compression.ZipFile]::OpenRead($tmp.FullName)

$entries = $zip.Entries | Where-Object {-not [string]::IsNullOrWhiteSpace($_.Name) } #| where {$_.FullName -like 'myzipdir/c/*' -and $_.FullName -ne 'myzipdir/c/'} 

#create dir for result of extraction
#New-Item -ItemType Directory -Path "c:\temp\c" -Force

#extraction
foreach($entry in $entries)
{
    $dpath = $destPath + $entry.Name
    [IO.Compression.ZipFileExtensions]::ExtractToFile( $entry, $dpath, $true)
}
#$entries | ForEach-Object {[IO.Compression.ZipFileExtensions]::ExtractToFile( $_, $destPath + $_.Name, $true) }

#free object
$zip.Dispose()

# set environment path vartiable
[Environment]::SetEnvironmentVariable("Path",[Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\Program Files\OpenSSH",[EnvironmentVariableTarget]::Machine)

# remove temporary file
$tmp | Remove-Item

# create firewall rule
if(-not (get-netfirewallrule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue))
{
    New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

# remove old capabilities
if((Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*").State -eq "Installed")
{
    Remove-WindowsCapability -Online  -Name  "OpenSSH.Server*"
}

if((Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Client*").State -eq "Installed")
{
    Remove-WindowsCapability -Online  -Name  "OpenSSH.Client*"
}

# change default ssh shell to powershell
$pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
if(Test-Path $pwshPath -PathType Leaf)
{
    if(!(Test-Path "HKLM:\SOFTWARE\OpenSSH"))
    {
        New-Item 'HKLM:\Software\OpenSSH' -Force
    }
    #New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String –Force
    #New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String –Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $pwshPath -PropertyType String –Force
}

# try to run installation script
if(Test-Administrator)
{
    & $installScriptPath
}

#setup sshd service startup type and start it
if(Get-Service  sshd -ErrorAction SilentlyContinue)
{
    # if((get-service sshd).StartType -eq [System.ServiceProcess.ServiceStartMode]::Manual)
    Get-Service -Name sshd | Set-Service -StartupType 'Automatic'
    Start-Service sshd
}


# exit











# # Below commands in arbitrary order for installation OpenSSH to a Windows system
# # few helpfull items
# # Powershell strip quotes when call cmd command
# # find  """22"""
# # find  '"22"'
# # find  "`"22`""

# # far
# # https://www.farmanager.com/files/Far30b5600.x86.20200518.7z

# Invoke-WebRequest -Uri https://wsldownload.azureedge.net/Ubuntu_1604.2019.523.0_x64.appx -OutFile Ubuntu.appx -UseBasicParsing

# # wsl
# Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# #[bool](New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  

# [Environment]::SetEnvironmentVariable("Path",[Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\Program Files\OpenSSH",[EnvironmentVariableTarget]::Machine)

# get-itemproperty -Path "HKCU:\Control Panel\Accessibility\Blind Access" -Name On

# set-itemproperty -Path "HKCU:\Control Panel\Accessibility\Blind Access" -Name On -Value 0

# Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*"
# Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Client*"

# Add-WindowsCapability -Online -Name "OpenSSH.Server*"

# Get-Service -Name sshd | Format-List *

# Get-Service -Name sshd | Set-Service -StartupType 'Automatic'

# Get-Service -Name sshd | Start-Service

# netstat -na | find '":22"'

# get-netfirewallrule -Name "OpenSSH-Server-In-TCP" | Select-Object Name, DisplayName, Description, Enabled

# New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String –Force

# New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String –Force