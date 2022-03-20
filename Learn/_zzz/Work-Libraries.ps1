
# Enumarate existing libraries

Add-type -path Microsoft.WindowsAPICodePack.Shell.dll

[Microsoft.WindowsAPICodePack.Shell.KnownFolders]::Libraries | Select-Object Name,ParsingName