

# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\BTHENUM



$desktop = [Environment]::GetFolderPath('Desktop' )
$path = Join-Path -Path $desktop -ChildPath 'bluetooth.lnk'
$shell = New-Object -ComObject WScript.Shell
$scut = $shell.CreateShortcut($path)
$scut.TargetPath = 'explorer.exe'
$scut.Arguments = 'ms-settings-connectabledevices:devicediscovery'
$scut.IconLocation = 'fsquirt.exe,0'
$scut.Save() 