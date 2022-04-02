

[Environment]::GetFolderPath('StartMenu') | 
Get-ChildItem -Filter *.lnk -Recurse |
ForEach-Object { $scut = New-Object -ComObject WScript.Shell } {
  $scut.CreateShortcut($_.FullName)
} 


# Create new Shortcut 
$path = [Environment]::GetFolderPath('Desktop') | Join-Path -ChildPath 'myLink.lnk'
$scut = (New-Object -ComObject WScript.Shell).CreateShortcut($path)
$scut.TargetPath = 'powershell.exe'
$scut.IconLocation = 'powershell.exe,0'
$scut.Save()


# launch LNK file as Administrator
# THIS PATH MUST EXIST (use previous script to create the LNK file or create one manually)
$path = [Environment]::GetFolderPath('Desktop') | Join-Path -ChildPath 'myLink.lnk'
# read LNK file as bytes...
$bytes = [System.IO.File]::ReadAllBytes($path)
# flip a bit in byte 21 (0x15)
$bytes[0x15] = $bytes[0x15 ] -bor 0x20 
# update the bytes
[System.IO.File]::WriteAllBytes($path, $bytes) 

# Flip the bit back into place to remove the Admin privilege feature from any LNK file:
$bytes[0x15] = $bytes[0x15 ] -band -not 0x20