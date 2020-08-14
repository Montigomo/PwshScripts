#

function Get-ComFolderItem() {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)] $Path
    )

    $ShellApp = New-Object -ComObject 'Shell.Application'

    $Item = Get-Item $Path -ErrorAction Stop

    if ($Item -is [System.IO.FileInfo]) {
        $ComFolderItem = $ShellApp.Namespace($Item.Directory.FullName).ParseName($Item.Name)
    } elseif ($Item -is [System.IO.DirectoryInfo]) {
        $ComFolderItem = $ShellApp.Namespace($Item.Parent.FullName).ParseName($Item.Name)
    } else {
        throw "Path is not a file nor a directory"
    }

    return $ComFolderItem
}

function Install-TaskBarPinnedItem() {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)] [System.IO.FileInfo] $Item
    )

    $Pinned = Get-ComFolderItem -Path $Item

    $Pinned.invokeverb('taskbarpin')
}

function Uninstall-TaskBarPinnedItem() {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)] [System.IO.FileInfo] $Item
    )

    $Pinned = Get-ComFolderItem -Path $Item

    $Pinned.invokeverb('taskbarunpin')
}

function Set-RegistryKey
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $RegistryPath,
        [string]
        $RegistryLeafValue,
        [ValidateSet("String", "ExpandString", "Binary", "DWord", "MultiString", "Qword", "Unknown")]
        [string]
        $PropertyType
    )

    $registryKey = [System.IO.Path]::GetDirectoryName($RegistryPath)
    $registryLeaf =[System.IO.Path]::GetFileName($RegistryPath)
    
    if(!(Test-Path ($registryKey))){
        New-Item $registryKey -Force
    }
    
    If (Get-ItemProperty -Path $registryKey -Name $registryLeaf -ErrorAction SilentlyContinue){
        Set-ItemProperty -Path $registryKey -Name $registryLeaf $RegistryLeafValue
    } Else {
        New-ItemProperty -Path $registryKey -Name $registryLeaf -PropertyType $PropertyType -Value $RegistryLeafValue -Force
        Set-ItemProperty -Path $registryKey -Name $registryLeaf $RegistryLeafValue
        #Write-Output 'Value : $registryPath does not exists'
    }
}


# turn off fast boot
# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power
# HiberbootEnabled DWORD
# 0 = Turn off fast startup
# 1 = Turn on fast startup
Set-RegistryKey -RegistryPath "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power\HiberbootEnabled" -RegistryLeafValue 0

#rename computer

Rename-Computer -NewName "AgiG75v"

#change workgroup


#install modules

# disable UAC
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
##New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force

#  WINDOWS REGISTRY:
#  Primary Key: [HKEY_CURRENT_USER\Keyboard Layout\Toggle]
#  Optional Secondary Key (might be needed for Windows logon screen): [HKEY_USERS\.DEFAULT\Keyboard Layout\Toggle]
#  Values: "Language Hotkey" and "Layout Hotkey"
# 1 = Key Sequence enabled; use LEFT ALT+SHIFT to switch between locales.
# 2 = Key Sequence enabled; use CTRL+SHIFT to switch between locales.
# 3 = Key Sequences disabled.

Set-RegistryKey -RegistryPath "REGISTRY::HKEY_CURRENT_USER\Keyboard Layout\Toggle\Language HotKey" -RegistryLeafValue 2
Set-RegistryKey -RegistryPath "REGISTRY::HKEY_CURRENT_USER\Keyboard Layout\Toggle\Layout HotKey" -RegistryLeafValue 2

#New-Item "REGISTRY::HKEY_CURRENT_USER\Keyboard Layout\Toggle\Language HotKey" -Force
#New-ItemProperty -Path "REGISTRY::HKEY_CURRENT_USER\Keyboard Layout\Toggle\Language HotKey"  -Name Test -PropertyType String -Value 2 -Force

# change start menu width

# show more tiles on start
# HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer
# NoChangeStartMenu DWORD
# (delete) = Enable
# 1 = Disable


# change System locale for nonunicode



exit

#remove all tiles from start

try
{
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() |
    Where-Object{$_.Name -eq $appname}).Verbs() | 
    Where-Object{$_.Name.replace('&','') -match 'From "Start" UnPin|Unpin from Start'} | 
    ForEach-Object{$_.DoIt()}
}
catch
{
    Write-Error "Error Pinning/Unpinning App! (App-Name correct?)"
}

(New-Object -Com Shell.Application).
    NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').
    Items() |
  %{ $_.Verbs() } |
  ?{$_.Name -match 'Un.*pin from Start'} |
  %{$_.DoIt()}